//
//  ViewController.swift
//  Corticoid
//
//  Created by Mai Hưng on 12/30/17.
//  Copyright © 2017 Hung Doan. All rights reserved.
//

import UIKit
import FolioReaderKit

class ViewController: FolioReaderContainer {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupBook()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setupBook() {
        let config = FolioReaderConfig()
        config.scrollDirection = .horizontalWithVerticalContent
        config.allowSharing = false
        config.enableTTS = false
        config.shouldHideNavigationOnTap = false	
        
        let bookPath = Bundle.main.path(forResource: "corticoid", ofType: "epub")
        setupConfig(config, epubPath: bookPath ?? "")
    }
}

