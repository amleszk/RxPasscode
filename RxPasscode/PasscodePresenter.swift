
import UIKit
import RxSwift
import RxCocoa

class PasscodePresenter {
    
    private var presentedWindow: UIWindow?
    private var passcodeLockWindow: UIWindow!
    private var disposeBag: DisposeBag = DisposeBag()
    static let sharedInstance = PasscodePresenter()
    
    init() {
        hookApplicationWillResignActive()
    }
    
    func hookApplicationWillResignActive() {
        NSNotificationCenter.defaultCenter().rx_notification(UIApplicationWillResignActiveNotification).subscribeNext { _ in
            if !PasscodePresenter.sharedInstance.isShowingPasscode() {
                PasscodePresenter.sharedInstance.presentInKeyWindow()
            }
        }.addDisposableTo(disposeBag)
    }
    
    func isShowingPasscode() -> Bool {
        return UIApplication.sharedApplication().keyWindow == passcodeLockWindow
    }
    
    func presentInKeyWindow() {
        presentedWindow = UIApplication.sharedApplication().keyWindow
        guard let presentedWindow = presentedWindow else {
            return
        }
        
        let imageView = UIImageView(image: presentedWindow.screenShotView())
        
        presentedWindow.windowLevel = 1
        presentedWindow.endEditing(true)
        
        passcodeLockWindow = PasscodeWindow(frame: UIScreen.mainScreen().bounds)
        passcodeLockWindow.windowLevel = 2
        passcodeLockWindow.makeKeyAndVisible()
        
        let passcodeLockViewController = PasscodeLockViewController(backgroundView: imageView) { passcode in
            return false
            //self.dismiss()
        }        
        passcodeLockWindow.rootViewController = passcodeLockViewController
    }
    
    func dismiss() {
        passcodeLockWindow.hidden = true
        presentedWindow?.becomeKeyWindow()
    }
}

class PasscodeWindow : UIWindow {
    
}