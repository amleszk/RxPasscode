
import UIKit

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
        let imageView = UIImageView(image: presentedWindow.screenShotView())
        
        presentedWindow.windowLevel = 1
        presentedWindow.endEditing(true)
        
        passcodeLockWindow.windowLevel = 2
        passcodeLockWindow.makeKeyAndVisible()
        passcodeLockWindow.rootViewController = PasscodeLockViewController(backgroundView: imageView)
        
    }
    
    func dismiss() {
        passcodeLockWindow.hidden = true
        presentedWindow.becomeKeyWindow()
    }
}
