//
//  CustomTabmanBar.swift
//  Tabman-Example
//
//  Created by Merrick Sapsford on 03/03/2017.
//  Copyright © 2017 Merrick Sapsford. All rights reserved.
//

import UIKit
import Tabman
import Pageboy

class CustomTabmanBar: TabmanBar {

    // MARK: Lifecycle
    
    override var intrinsicContentSize: CGSize {
        // return your custom size here if required
        return super.intrinsicContentSize
    }
    
    // MARK: TabmanBar Lifecycle
    
    override func constructTabBar(items: [TabmanBarItem]) {
        super.constructTabBar(items: items)
        
        // create your tab here
    }
    
    override func update(forPosition position: CGFloat,
                         direction: PageboyViewController.NavigationDirection,
                         minimumIndex: Int, maximumIndex: Int) {
        super.update(forPosition: position, direction: direction,
                     minimumIndex: minimumIndex, maximumIndex: maximumIndex)
        
        // update the tab bar for a position here
    }
    
    override func update(forAppearance appearance: TabmanBar.AppearanceConfig) {
        super.update(forAppearance: appearance)
        
        // update the tab bar appearance here
    }
}
