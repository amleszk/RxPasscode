
import UIKit
import RxSwift
import RxCocoa

internal let privateSharedInstance = PasscodePresenter()

class PasscodePresenter: NSObject {
    
    private var presentedWindow: UIWindow?
    private var passcodeLockWindow: UIWindow!
    private var disposeBag: DisposeBag = DisposeBag()
    
    class var sharedInstance: PasscodePresenter {
        return privateSharedInstance
    }
    
    override init() {
        super.init()
        hookApplicationWillResignActive()
    }
    
    func hookApplicationWillResignActive() {
        NSNotificationCenter.defaultCenter().rx_notification(UIApplicationWillResignActiveNotification).subscribeNext { _ in
            if !PasscodePresenter.sharedInstance.isShowingPasscode() {
                PasscodePresenter.sharedInstance.presentWithValidatePasscode()
            }
            }.addDisposableTo(disposeBag)
    }
    
    func isShowingPasscode() -> Bool {
        return UIApplication.sharedApplication().keyWindow == passcodeLockWindow
    }
    
    func presentWithValidatePasscode() {
        guard let imageView = screenshotAndPresentNewWindow() else {
            return
        }
        var numberOfTries = 0
        let maxPasscodeTries = 3
        let existingPasscode: [Int] = [1,2,3,4]
        let passcodeLockViewController = PasscodeLockViewController(backgroundView: imageView, validateCode: { passcode in
            //TODO: check keychain for existing passcode
            if passcode == existingPasscode {
                return .Accepted
            } else {
                numberOfTries += 1
                if numberOfTries >= maxPasscodeTries {
                    
                }
                return .Invalid
            }
            }, unlocked: {
                self.dismiss()
        })
        passcodeLockWindow.rootViewController = passcodeLockViewController
    }
    
    func presentWithNewPasscode() {
        guard let imageView = screenshotAndPresentNewWindow() else {
            return
        }
        var newPasscode: [Int] = []
        let passcodeLockViewController = PasscodeLockViewController(backgroundView: imageView, validateCode: { passcode in
            if newPasscode.count == 0 {
                newPasscode = passcode
                return .ReEnter
            } else if newPasscode == passcode {
                //TODO: save passcode in keychain
                return .Accepted
            } else {
                return .Invalid
            }
            }, unlocked: {
                self.dismiss()
        })
        passcodeLockViewController.cancelButtonEnabled = true
        passcodeLockWindow.rootViewController = passcodeLockViewController
    }
    
    func presentWithChangePasscode() {
        guard let imageView = screenshotAndPresentNewWindow() else {
            return
        }
        //TODO: stubbed
        let existingPasscode: [Int] = [1,2,3,4]
        var validated = false
        var newPasscode: [Int] = []
        let passcodeLockViewController = PasscodeLockViewController(backgroundView: imageView, validateCode: { passcode in
            if !validated {
                if existingPasscode == passcode {
                    validated = true
                    return .EnterNew
                } else {
                    return .Invalid
                }
            } else {
                if newPasscode.count == 0 {
                    newPasscode = passcode
                    return .ReEnter
                } else if newPasscode == passcode {
                    //TODO: save passcode in keychain 'newPasscode'
                    return .Accepted
                } else {
                    return .Invalid
                }
            }
            }, unlocked: {
                self.dismiss()
        })
        passcodeLockViewController.cancelButtonEnabled = true
        passcodeLockWindow.rootViewController = passcodeLockViewController
    }
    
    func presentTooManyTriesAlert() {
        
    }
    
    func dismiss() {
        passcodeLockWindow.hidden = true
        passcodeLockWindow.rootViewController = nil
        presentedWindow?.becomeKeyWindow()
    }
    
    private func screenshotAndPresentNewWindow() -> UIImageView? {
        presentedWindow = UIApplication.sharedApplication().keyWindow
        guard let presentedWindow = presentedWindow else {
            return nil
        }
        
        let imageView = UIImageView(image: presentedWindow.screenShotView())
        
        presentedWindow.windowLevel = 1
        presentedWindow.endEditing(true)
        
        passcodeLockWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
        passcodeLockWindow.windowLevel = 2
        passcodeLockWindow.makeKeyAndVisible()
        
        return imageView
    }
}
