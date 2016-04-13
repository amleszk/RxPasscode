
import UIKit
import RxSwift
import RxCocoa

internal let privateSharedInstance = PasscodePresenter()
internal let passcodeMaxNumberTries = 3

@objc
protocol PasscodeDatasource: class {
    func passcode() -> [Int]
    func didSetNewPasscode(passcode: [Int])
    func didFailAllPasscodeAttempts()
}

class PasscodePresenter: NSObject {
    
    typealias PresentationCompletion = (Bool -> Void)
    
    private var presentedWindow: UIWindow!
    private var keyWindowSavedWindowLevel: CGFloat!
    private var passcodeLockWindow: UIWindow!
    private var disposeBag: DisposeBag = DisposeBag()
    
    var passcodeDatasource: PasscodeDatasource?
    
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
    
    func presentWithValidatePasscode(allowCancel: Bool = false, completion: PresentationCompletion? = nil) {
        guard let imageView = screenshotAndPresentNewWindow() else {
            return
        }
        var numberOfTries = 0
        let existingPasscode: [Int] = passcodeDatasource!.passcode()
        let passcodeLockViewController = PasscodeLockViewController(backgroundView: imageView, validateCode: { passcode in
            if passcode == existingPasscode {
                return .Accepted
            } else {
                numberOfTries += 1
                if numberOfTries >= passcodeMaxNumberTries {
                    self.passcodeDatasource!.didFailAllPasscodeAttempts()
                }
                return .Invalid
            }
        }, unlocked: { didCancel in
            completion?(didCancel)
            self.dismiss()
        })
        if let statusbarStyle = presentedWindow.rootViewController?.preferredStatusBarStyle() {
            passcodeLockViewController.statusBarStyle = statusbarStyle
        }
        passcodeLockViewController.cancelButtonEnabled = allowCancel
        passcodeLockWindow.rootViewController = passcodeLockViewController
    }
    
    func presentWithNewPasscode(completion: PresentationCompletion? = nil) {
        guard let imageView = screenshotAndPresentNewWindow() else {
            return
        }
        var newPasscode: [Int] = []
        let passcodeLockViewController = PasscodeLockViewController(backgroundView: imageView, validateCode: { passcode in
            if newPasscode.count == 0 {
                newPasscode = passcode
                return .ReEnter
            } else if newPasscode == passcode {
                self.passcodeDatasource!.didSetNewPasscode(newPasscode)
                return .Accepted
            } else {
                return .Invalid
            }
        }, unlocked: { didCancel in
            completion?(didCancel)
            self.dismiss()
        })
        if let statusbarStyle = presentedWindow.rootViewController?.preferredStatusBarStyle() {
            passcodeLockViewController.statusBarStyle = statusbarStyle
        }
        passcodeLockViewController.cancelButtonEnabled = true
        passcodeLockWindow.rootViewController = passcodeLockViewController
    }
    
    func presentWithChangePasscode(completion: PresentationCompletion? = nil) {
        guard let imageView = screenshotAndPresentNewWindow() else {
            return
        }
        var numberOfTries = 0
        let existingPasscode: [Int] = passcodeDatasource!.passcode()
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
                    self.passcodeDatasource!.didSetNewPasscode(newPasscode)
                    return .Accepted
                } else {
                    numberOfTries += 1
                    if numberOfTries >= passcodeMaxNumberTries {
                        self.passcodeDatasource!.didFailAllPasscodeAttempts()
                    }
                    return .Invalid
                }
            }
        }, unlocked: { didCancel in
            completion?(didCancel)
            self.dismiss()
        })
        if let statusbarStyle = presentedWindow.rootViewController?.preferredStatusBarStyle() {
            passcodeLockViewController.statusBarStyle = statusbarStyle
        }
        passcodeLockViewController.cancelButtonEnabled = true
        passcodeLockWindow.rootViewController = passcodeLockViewController
    }
    
    func dismiss() {
        passcodeLockWindow.hidden = true
        passcodeLockWindow.windowLevel = 0
        presentedWindow.windowLevel = keyWindowSavedWindowLevel
        presentedWindow.becomeKeyWindow()
    }
    
    private func screenshotAndPresentNewWindow() -> UIImageView? {
        presentedWindow = UIApplication.sharedApplication().keyWindow
        guard let presentedWindow = presentedWindow else {
            return nil
        }
        
        let imageView = UIImageView(image: presentedWindow.screenShotView())
        
        keyWindowSavedWindowLevel = presentedWindow.windowLevel
        presentedWindow.windowLevel = 1
        presentedWindow.endEditing(true)
        
        passcodeLockWindow = PasscodeWindow(frame: UIScreen.mainScreen().bounds)
        passcodeLockWindow.windowLevel = 2
        passcodeLockWindow.makeKeyAndVisible()
        return imageView
    }
}

class PasscodeWindow: UIWindow {
    
}
