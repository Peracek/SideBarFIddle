//
//  MainVC.swift
//  SideBarFiddle
//
//  Created by Pavel Peroutka on 27/10/2017.
//  Copyright © 2017 Pavel Peroutka. All rights reserved.
//

import UIKit

class MainVC: UITabBarController {
    
    public var mainVCDelegate: MainVCDelegate?

    @IBAction public func toggleSideBart(_ sender: UIBarButtonItem) {
        mainVCDelegate?.toggleSideBar()
    }
    
    public func presentView(at position: Int) {
        self.selectedIndex = position
    }
}

protocol MainVCDelegate {
    func toggleSideBar()
}
