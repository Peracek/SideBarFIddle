//
//  SideBarVC.swift
//  SideBarFiddle
//
//  Created by Pavel Peroutka on 27/10/2017.
//  Copyright © 2017 Pavel Peroutka. All rights reserved.
//
//  Gesta na vytahovani a zathovani menu maji spousta chyb. Nedaji se prerusovat,
//  pri prepnuti do .ended se vzdy sideBarOpened nastavi vzdy do opacneho stavu,
//  a tak dale... s trochou trpelivosti to nebude tezke dotahnu do dokonalosti:)

import UIKit

class SideBarVC: UIViewController, MainVCDelegate, UITableViewDelegate {

    @IBOutlet weak var sideBarLeading: NSLayoutConstraint!    
    @IBOutlet weak var sideBar: UIView!
    @IBOutlet weak var main: UIView!
    
    private var sideBarTableVC: UITableViewController!
    private var mainVC: MainVC!
    
    private var screenPan: UIPanGestureRecognizer!
    private var tap: UITapGestureRecognizer!
    
    private var sideBarOpened = false {
        didSet {
            if sideBarOpened {
                sideBarLeading.constant = 0
                // just for funzies
                (screenPan.isEnabled, tap.isEnabled) = (true, true)
            } else {
                sideBarLeading.constant = -sideBarWidth
                screenPan.isEnabled = false
                tap.isEnabled = false
            }
            animateLayoutIfNeeded()
        }
    }
    private lazy var sideBarWidth: CGFloat = { return self.sideBar.bounds.width }()
    
    override func viewDidLoad() {
        let leftEdgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(edgePanSideBar(_:)))
        leftEdgePan.edges = .left
        view.addGestureRecognizer(leftEdgePan)
        
        screenPan = UIPanGestureRecognizer(target: self, action: #selector(screenPanSideBar(_:)))
        screenPan.isEnabled = false
        view.addGestureRecognizer(screenPan)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(tapHideSideBar(_:)))
        tap.isEnabled = false
        // adding to main view here!
        main.addGestureRecognizer(tap)
    }
    
    @objc private func edgePanSideBar(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            let translation = recognizer.translation(in: view)
            sideBarLeading.constant = (sideBarLeading.constant + translation.x).withinBounds(min: -sideBarWidth, max: 0)
            recognizer.setTranslation(CGPoint.zero, in: view)
        }
        if recognizer.state == .ended {
            sideBarOpened = !sideBarOpened
        }
    }
    
    @objc private func screenPanSideBar(_ recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            let translation = recognizer.translation(in: view)
            sideBarLeading.constant = (sideBarLeading.constant + translation.x).withinBounds(min: -sideBarWidth, max: 0)
            recognizer.setTranslation(CGPoint.zero, in: view)
        }
        if recognizer.state == .ended {
            sideBarOpened = !sideBarOpened
        }
    }
    
    @objc private func tapHideSideBar(_ recognizer: UITapGestureRecognizer) {
        sideBarOpened = false
    }
    
    // initialize child controller vars
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "sideBar":
                sideBarTableVC = segue.destination as! UITableViewController
                sideBarTableVC.tableView.delegate = self
            case "main":
                mainVC = segue.destination.contentViewController as! MainVC
                mainVC.mainVCDelegate = self
            default:
                break
            }
        }
    }
    
    func animateLayoutIfNeeded() {
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Implementation of MainVCDelegate
    func toggleSideBar() {
        sideBarOpened = !sideBarOpened
    }
    
    // MARK: - Implementation of UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let position = indexPath.row
        mainVC.presentView(at: position)
        toggleSideBar()
    }
}

extension UINavigationController {
    var rootViewController : UIViewController? {
        return viewControllers.first
    }
}

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.rootViewController ?? self
        }
        return self
    }
}

extension CGFloat {
    func withinBounds(min: CGFloat, max: CGFloat) -> CGFloat {
        return Swift.min(max, Swift.max(min, self))
    }
}
