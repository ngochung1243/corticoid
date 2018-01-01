//
//  HMBookmarkList.swift
//  Corticoid
//
//  Created by Mai Hưng on 12/31/17.
//  Copyright © 2017 Hung Doan. All rights reserved.
//

import UIKit

class HMBookmarkList: UITableViewController {
    var bookmarks = [HMBookmark]()
    let reader: FolioReader
    let config: FolioReaderConfig
    
    init(reader: FolioReader, config: FolioReaderConfig) {
        self.reader = reader
        self.config = config
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let storedBookmarks = HMBookmarkManager.sharedInstance.loadBookmark() {
            bookmarks = storedBookmarks
        }
        
        tableView.register(HMBookmarkCell.self, forCellReuseIdentifier: HMBookmarkCell.description())
        tableView.rowHeight = 85
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.backgroundColor = reader.isNight(config.nightModeMenuBackground, config.menuBackgroundColor)
        tableView.separatorColor = reader.isNight(config.nightModeSeparatorColor, config.menuSeparatorColor)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return bookmarks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HMBookmarkCell.description(), for: indexPath) as! HMBookmarkCell
        cell.load(bookmark: bookmarks[indexPath.row], reader: reader, config: config)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let bookmark = bookmarks[safe: (indexPath as NSIndexPath).row] else {
            return
        }
        
        reader.readerCenter?.changePageWith(page: bookmark.page)
        self.dismiss()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let bookmark = bookmarks[(indexPath as NSIndexPath).row]
            if (HMBookmarkManager.sharedInstance.remove(bookmark: bookmark)) {
                bookmarks.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
}

class HMBookmarkCell: UITableViewCell {
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Medium", size: 12)
        label.frame = CGRect(x: 20, y: 10, width: self.contentView.frame.size.width - 40, height: label.font.lineHeight)
        label.autoresizingMask = UIViewAutoresizing.flexibleWidth
        return label
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Medium", size: 14)
        label.frame = CGRect(x: 20, y: 35, width: self.contentView.frame.size.width - 40, height: label.font.lineHeight)
        label.autoresizingMask = UIViewAutoresizing.flexibleWidth
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    lazy var pageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Medium", size: 12)
        label.frame = CGRect(x: 20, y: 55, width: self.contentView.frame.size.width - 40, height: label.font.lineHeight)
        label.autoresizingMask = UIViewAutoresizing.flexibleWidth
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(dateLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(pageLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load(bookmark: HMBookmark, reader: FolioReader, config: FolioReaderConfig) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = config.localizedHighlightsDateFormat
        let dateString = dateFormatter.string(from: bookmark.date)
        dateLabel.text = dateString
        dateLabel.textColor = reader.isNight(UIColor(white: 5, alpha: 0.3), UIColor.lightGray)
        
        titleLabel.text = bookmark.title ?? ""
        titleLabel.textColor = reader.isNight(config.menuTextColor, UIColor.black)
        
        pageLabel.text = NSLocalizedString("Page: \(bookmark.page ?? 0)", comment: "")
        pageLabel.textColor = reader.isNight(config.menuTextColor, UIColor.black)
        
        self.backgroundColor = reader.isNight(config.nightModeMenuBackground, config.menuBackgroundColor)
        contentView.backgroundColor = reader.isNight(config.nightModeMenuBackground, config.menuBackgroundColor)
    }
}
