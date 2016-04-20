
import UIKit
import RxSwift
import RxCocoa

internal let passcodePresenterSharedInstance = PasscodePresenter()
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
    private var passcodeLockWindow: PasscodeWindow!
    private var disposeBag: DisposeBag = DisposeBag()
    
    var passcodeDatasource: PasscodeDatasource?
    
    class var sharedInstance: PasscodePresenter {
        return passcodePresenterSharedInstance
    }
    
    override init() {
        super.init()
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
    
    func presentWithBlurBackground() {
        screenshotAndPresentPasscodeWindowIfNeeded()
    }
    
    func presentWithValidatePasscode(allowCancel: Bool = false, completion: PresentationCompletion? = nil) {
        screenshotAndPresentPasscodeWindowIfNeeded()
        guard let passcodeDatasource = passcodeDatasource else {
            return
        }
        var numberOfTries = 0
        let existingPasscode: [Int] = passcodeDatasource.passcode()
        let passcodeLockViewController = PasscodeLockViewController(validateCode: { passcode in
            if passcode == existingPasscode {
                return .Accepted
            } else {
                numberOfTries += 1
                if numberOfTries >= passcodeMaxNumberTries {
                    passcodeDatasource.didFailAllPasscodeAttempts()
                }
                return .Invalid
            }
        }, dismiss: { didCancel in
            self.dismiss {
                completion?(didCancel)
            }
        })
        if let statusbarStyle = presentedWindow.rootViewController?.preferredStatusBarStyle() {
            passcodeLockViewController.statusBarStyle = statusbarStyle
        }
        passcodeLockViewController.cancelButtonEnabled = allowCancel
        passcodeLockWindow.rootViewController = passcodeLockViewController
    }
    
    func presentWithNewPasscode(completion: PresentationCompletion? = nil) {
        screenshotAndPresentPasscodeWindowIfNeeded()
        guard let passcodeDatasource = passcodeDatasource else {
            return
        }
        var newPasscode: [Int] = []
        let passcodeLockViewController = PasscodeLockViewController(validateCode: { passcode in
            if newPasscode.count == 0 {
                newPasscode = passcode
                return .ReEnter
            } else if newPasscode == passcode {
                passcodeDatasource.didSetNewPasscode(newPasscode)
                return .Accepted
            } else {
                return .Invalid
            }
        }, dismiss: { didCancel in
            self.dismiss {
                completion?(didCancel)
            }
        })
        if let statusbarStyle = presentedWindow.rootViewController?.preferredStatusBarStyle() {
            passcodeLockViewController.statusBarStyle = statusbarStyle
        }
        passcodeLockViewController.cancelButtonEnabled = true
        passcodeLockWindow.rootViewController = passcodeLockViewController
    }
    
    func presentWithChangePasscode(completion: PresentationCompletion? = nil) {
        screenshotAndPresentPasscodeWindowIfNeeded()
        guard let passcodeDatasource = passcodeDatasource else {
            return
        }
        var numberOfTries = 0
        let existingPasscode: [Int] = passcodeDatasource.passcode()
        var validated = false
        var newPasscode: [Int] = []
        let passcodeLockViewController = PasscodeLockViewController(validateCode: { passcode in
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
                    passcodeDatasource.didSetNewPasscode(newPasscode)
                    return .Accepted
                } else {
                    numberOfTries += 1
                    if numberOfTries >= passcodeMaxNumberTries {
                        passcodeDatasource.didFailAllPasscodeAttempts()
                    }
                    return .Invalid
                }
            }
        }, dismiss: { didCancel in
            self.dismiss {
                completion?(didCancel)
            }
        })
        if let statusbarStyle = presentedWindow.rootViewController?.preferredStatusBarStyle() {
            passcodeLockViewController.statusBarStyle = statusbarStyle
        }
        passcodeLockViewController.cancelButtonEnabled = true
        passcodeLockWindow.rootViewController = passcodeLockViewController
    }
    
    func dismiss(completion: ((Void) -> (Void))? = nil) {
        passcodeLockWindow.fadeOutAnimated {
            self.passcodeLockWindow.hidden = true
            self.passcodeLockWindow.windowLevel = 0
            self.presentedWindow.windowLevel = self.keyWindowSavedWindowLevel
            self.presentedWindow.becomeKeyWindow()
            completion?()
        }
    }
    
    private func screenshotAndPresentPasscodeWindowIfNeeded() {
        if isShowingPasscode() {
            return
        }
        presentedWindow = UIApplication.sharedApplication().keyWindow
        guard let presentedWindow = presentedWindow else {
            return
        }
        
        let imageView = UIImageView(image: presentedWindow.screenShotView())
        
        keyWindowSavedWindowLevel = presentedWindow.windowLevel
        presentedWindow.windowLevel = 1
        presentedWindow.endEditing(true)
        
        passcodeLockWindow = PasscodeWindow(backgroundView: imageView)
        passcodeLockWindow.windowLevel = 2
        passcodeLockWindow.rootViewController = HiddenViewController(nibName: nil, bundle: nil)
        passcodeLockWindow.makeKeyAndVisible()
        passcodeLockWindow.fadeInAnimated()
        passcodeLockWindow.setNeedsDisplay()
    }
}
