//
//  ViewController.swift
//  Corticoid
//
//  Created by Mai Hưng on 12/30/17.
//  Copyright © 2017 Hung Doan. All rights reserved.
//

import UIKit
import EAIntroView

class ViewController: FolioReaderContainer {
    let config = FolioReaderConfig()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupBook()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        showIntro()
    }
    
    func setupBook() {
        
        config.scrollDirection = .horizontalWithVerticalContent
        config.allowSharing = true
        config.enableTTS = false
        config.shouldHideNavigationOnTap = false	
        
        let bookPath = Bundle.main.path(forResource: "corticoid", ofType: "epub")
        setupConfig(config, epubPath: bookPath ?? "")
    }
    
    func showIntro() {
        if UserDefaults.standard.object(forKey: "Intro") != nil {
            return
        }
        
        let introImageName = ["5.5_Screen_1", "5.5_Screen_2", "5.5_Screen_3", "5.5_Screen_4", "5.5_Screen_5"]
        
        var introPages = [EAIntroPage]()
        
        for i in 0..<introImageName.count {
            let page = EAIntroPage()
            page.bgImage = UIImage(named:introImageName[i])
            introPages.append(page)
        }
        
        let introView = EAIntroView(frame: self.view.frame, andPages: introPages)
        introView?.pageControl.pageIndicatorTintColor = UIColor.lightGray
        introView?.pageControl.currentPageIndicatorTintColor = config.tintColor
        introView?.skipButton.setTitleColor(config.tintColor, for: .normal)
        introView?.show(in: self.view)
        UserDefaults.standard.set(true, forKey: "Intro")
    }
}

