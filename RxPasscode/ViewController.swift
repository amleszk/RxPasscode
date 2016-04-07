//
//  ViewController.swift
//  RxPasscode
//
//  Created by al on 7/04/2016.
//  Copyright © 2016 RxPasscode. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var passcodePresenter: PasscodePresenter!
    
    override func viewDidAppear(animated: Bool) {
        self.view.backgroundColor = UIColor.blueColor()
        passcodePresenter = PasscodePresenter()
        passcodePresenter.presentInKeyWindow()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.passcodePresenter.dismiss()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }


}

class PasscodePresenter {
    
    let presentedWindow: UIWindow
    
    private lazy var passcodeLockWindow: UIWindow = {
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window.windowLevel = 0
        window.makeKeyAndVisible()
        return window
    }()
    
    init() {
        presentedWindow = UIApplication.sharedApplication().keyWindow!
    }
    
    func presentInKeyWindow() {
        presentedWindow.windowLevel = 1
        presentedWindow.endEditing(true)
        passcodeLockWindow.windowLevel = 2
        passcodeLockWindow.makeKeyAndVisible()
        passcodeLockWindow.rootViewController = PasscodeLockViewController()
        
    }
    
    func dismiss() {
        passcodeLockWindow.hidden = true
        presentedWindow.becomeKeyWindow()
    }
}

class PasscodeLockViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.redColor()
    }
    
}
