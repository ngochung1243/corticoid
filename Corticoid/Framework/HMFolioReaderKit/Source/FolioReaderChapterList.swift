//
//  FolioReaderChapterList.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 15/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
import Popover

/// Table Of Contents delegate
@objc protocol FolioReaderChapterListDelegate: class {
    /**
     Notifies when the user selected some item on menu.
     */
    func chapterList(_ chapterList: FolioReaderChapterList, didSelectRowAtIndexPath indexPath: IndexPath, withTocReference reference: FRTocReference)

    /**
     Notifies when chapter list did totally dismissed.
     */
    func chapterList(didDismissedChapterList chapterList: FolioReaderChapterList)
}

class FolioReaderChapterList: UITableViewController {

    weak var delegate: FolioReaderChapterListDelegate?
    fileprivate var tocItems = [FRTocReference]()
    fileprivate var book: FRBook
    fileprivate var readerConfig: FolioReaderConfig
    fileprivate var folioReader: FolioReader
    
    let popover = Popover()

    init(folioReader: FolioReader, readerConfig: FolioReaderConfig, book: FRBook, delegate: FolioReaderChapterListDelegate?) {
        self.readerConfig = readerConfig
        self.folioReader = folioReader
        self.delegate = delegate
        self.book = book

        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init with coder not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.tableView.register(FolioReaderChapterListCell.self, forCellReuseIdentifier: kReuseCellIdentifier)
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.backgroundColor = self.folioReader.isNight(self.readerConfig.nightModeMenuBackground, self.readerConfig.menuBackgroundColor)
        self.tableView.separatorColor = self.folioReader.isNight(self.readerConfig.nightModeSeparatorColor, self.readerConfig.menuSeparatorColor)

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50

        // Create TOC list
        self.tocItems = self.book.flatTableOfContents
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : tocItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kReuseCellIdentifier, for: indexPath) as! FolioReaderChapterListCell
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.backgroundColor = UIColor.clear
        cell.setup(withConfiguration: self.readerConfig)
        
        switch indexPath.section {
        case 0:
            cell.indexLabel?.text = "GIỚI THIỆU SÁCH"
            let fontDescriptor = cell.indexLabel?.font.fontDescriptor.withSymbolicTraits(.traitBold)
            let boldFont = UIFont(descriptor: fontDescriptor!, size: 15)
            cell.indexLabel?.font = boldFont
        case 1:
            cell.setup(withConfiguration: self.readerConfig)
            let tocReference = tocItems[(indexPath as NSIndexPath).row]
            let isSection = tocReference.children.count > 0
            
            cell.indexLabel?.text = tocReference.title.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Add audio duration for Media Ovelay
            if let resource = tocReference.resource {
                if let mediaOverlay = resource.mediaOverlay {
                    let duration = self.book.durationFor("#"+mediaOverlay)
                    
                    if let durationFormatted = (duration != nil ? duration : "")?.clockTimeToMinutesString() {
                        let text = cell.indexLabel?.text ?? ""
                        cell.indexLabel?.text = text + (duration != nil ? (" - " + durationFormatted) : "")
                    }
                }
            }
            
            // Mark current reading chapter
            if
                let currentPageNumber = self.folioReader.readerCenter?.currentPageNumber,
                let reference = self.book.spine.spineReferences[safe: currentPageNumber - 1],
                (tocReference.resource != nil) {
                let resource = reference.resource
                cell.indexLabel?.textColor = (tocReference.resource == resource ? self.readerConfig.tintColor : self.readerConfig.menuTextColor)
            }
            
            cell.contentView.backgroundColor = isSection ? UIColor(white: 0.7, alpha: 0.1) : UIColor.clear
            
        default:
            break;
        }
        
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let bookCoverView = UIImageView(image: UIImage(named: "Cover"))
            let closeButton = UIButton()
            closeButton.frame = CGRect(x: 20, y: 20, width: 24, height: 24)
            closeButton.setImage(UIImage(named: "ic_close")!.ignoreSystemTint(withConfiguration: self.readerConfig), for: .normal)
            closeButton.addTarget(self, action: #selector(closeBookCoverView), for: .touchUpInside)
            bookCoverView.addSubview(closeButton)
            bookCoverView.frame = UIScreen.main.bounds
            bookCoverView.isUserInteractionEnabled = true
            popover.show(bookCoverView, point: CGPoint(x: 0, y: 0))
        case 1:
            let tocReference = tocItems[(indexPath as NSIndexPath).row]
            delegate?.chapterList(self, didSelectRowAtIndexPath: indexPath, withTocReference: tocReference)
            dismiss {
                self.delegate?.chapterList(didDismissedChapterList: self)
            }
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func closeBookCoverView() {
        popover.dismiss()
    }
}
