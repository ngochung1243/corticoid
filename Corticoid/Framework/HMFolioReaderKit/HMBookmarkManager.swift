//
//  HMBookmarkManager.swift
//  FolioReaderKit
//
//  Created by Mai Hưng on 12/31/17.
//

import UIKit
import Foundation

let HMBookmarkKey: String = "HMBookmarkKey"

protocol HMBookmarkInterface {
    func loadBookmark() -> [HMBookmark]?;
    func add(bookmark: HMBookmark) -> Bool
    func remove(bookmark: HMBookmark) -> Bool
    func exisedBookmarkAtPage(_ page: Int) -> (Bool, Int)
    func removeBookmarkAtPage(_ page: Int) -> Bool
}

class HMUserDefaultBMAdapter: NSObject, HMBookmarkInterface {
    var bookmarks: [HMBookmark]?
    var bookmarkDicts: [NSDictionary]?
    
    func loadBookmark() -> [HMBookmark]? {
        if bookmarks != nil {
            return bookmarks
        }
        
        bookmarkDicts = UserDefaults.standard.array(forKey: HMBookmarkKey) as? [NSDictionary]
        if bookmarkDicts == nil {
            bookmarkDicts = [NSDictionary]()
            bookmarks = [HMBookmark]()
        } else {
            bookmarks = bookmarkDicts?.map({ (bookmarkDict) -> HMBookmark! in
                return HMBookmark(from: bookmarkDict)
            })
        }
        
        return bookmarks
    }
    
    func add(bookmark: HMBookmark) -> Bool {
        guard var bookmarks = loadBookmark(), var bookmarkDicts = bookmarkDicts else {
            return false
        }
        
        let (existed, _) = exisedBookmarkAtPage(bookmark.page)
        if existed {
            return true
        }
        
        bookmarks.append(bookmark)
        bookmarkDicts.append(bookmark.toDictionary())
        self.bookmarks = bookmarks
        self.bookmarkDicts = bookmarkDicts
        UserDefaults.standard.set(bookmarkDicts, forKey: HMBookmarkKey)
        UserDefaults.standard.synchronize()
        return true
    }
    
    func remove(bookmark: HMBookmark) -> Bool {
        guard var bookmarks = loadBookmark(),
            var bookmarkDicts = bookmarkDicts,
            let removeIndex = bookmarks.index(of: bookmark) else {
            return false
        }
        
        bookmarks.remove(at: removeIndex)
        bookmarkDicts.remove(at: removeIndex)
        self.bookmarks = bookmarks
        self.bookmarkDicts = bookmarkDicts
        UserDefaults.standard.set(bookmarkDicts, forKey: HMBookmarkKey)
        UserDefaults.standard.synchronize()
    
        return true
    }
    
    func removeBookmarkAtPage(_ page: Int) -> Bool {
        guard var bookmarks = loadBookmark(),
            var bookmarkDicts = bookmarkDicts else {
                return false
        }
        
        let (existed, index) = exisedBookmarkAtPage(page)
        if (existed) {
            bookmarks.remove(at: index)
            bookmarkDicts.remove(at: index)
            self.bookmarks = bookmarks
            self.bookmarkDicts = bookmarkDicts
            UserDefaults.standard.set(bookmarkDicts, forKey: HMBookmarkKey)
            UserDefaults.standard.synchronize()
            
            return true
        }
        
        return false
    }
    
    func exisedBookmarkAtPage(_ page: Int) -> (Bool, Int) {
        guard let bookmarks = loadBookmark() else {
            return (false, -1)
        }
        
        for index in 0..<bookmarks.count {
            let storedBookmark = bookmarks[index]
            if storedBookmark.page == page {
                return (true, index)
            }
        }
        
        return (false, -1)
    }
}

class HMBookmarkManager: NSObject {
    static let sharedInstance = HMBookmarkManager()
    
    var bookmarkAdapter: HMBookmarkInterface?
    
    override init() {
        bookmarkAdapter = HMUserDefaultBMAdapter()
        super.init()
    }
    
    func loadBookmark() -> [HMBookmark]? {
        return bookmarkAdapter?.loadBookmark()
    }
    
    func add(bookmark: HMBookmark) -> Bool {
        return bookmarkAdapter?.add(bookmark: bookmark) ?? false
    }
    
    func remove(bookmark: HMBookmark) -> Bool {
        return bookmarkAdapter?.remove(bookmark: bookmark) ?? false
    }
    
    func removeBookmarkAtPage(_ page: Int) -> Bool {
        return bookmarkAdapter?.removeBookmarkAtPage(page) ?? false
    }
    
    func exisedBookmarkAtPage(_ page: Int) -> Bool {
        let (result, _) = bookmarkAdapter?.exisedBookmarkAtPage(page) ?? (false, -1)
        return result
    }
}

class HMBookmark: NSObject {
    var title: String!
    var page: Int!
    var date: Foundation.Date!
    
    override init() {
        super.init()
        title = ""
        page = 0
        date = Foundation.Date()
    }
    
    static func object(from data: Data) -> HMBookmark? {
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? HMBookmark
    }
    
    convenience init(from dictionary: NSDictionary) {
        self.init()
        title = dictionary["title"] as! String
        page = dictionary["page"] as! Int
        let dateTime = dictionary["date"] as! Double
        date = Foundation.Date(timeIntervalSince1970: dateTime)
    }
    
    func toDictionary() -> NSDictionary {
        return ["title": title, "page": page, "date": date.timeIntervalSince1970]
    }
}
