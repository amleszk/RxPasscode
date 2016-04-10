
import UIKit

class PasscodePresenter {
    
    private var presentedWindow: UIWindow?
    private var passcodeLockWindow: UIWindow!
    static let sharedInstance = PasscodePresenter()
    
        
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
        passcodeLockWindow.rootViewController = PasscodeLockViewController(backgroundView: imageView)
    }
    
    func dismiss() {
        passcodeLockWindow.hidden = true
        presentedWindow?.becomeKeyWindow()
    }
}

class PasscodeWindow : UIWindow {
    
}