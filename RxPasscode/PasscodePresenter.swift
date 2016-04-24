
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
    func rootViewController() -> UIViewController?
}

class PasscodePresenter: NSObject {
    
    typealias PresentationCompletion = (Bool -> Void)
    
    private var passcodeView: PasscodeObstructionView!
    private var passcodeLockViewController: PasscodeLockViewController!
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
        return passcodeView?.window != nil
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
        passcodeLockViewController = PasscodeLockViewController(validateCode: { passcode in
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
            self.dismissAnimated(true) {
                completion?(didCancel)
            }
        })
        passcodeLockViewController.cancelButtonEnabled = allowCancel
        passcodeView.pinView(passcodeLockViewController.view)
    }
    
    func presentWithNewPasscode(completion: PresentationCompletion? = nil) {
        screenshotAndPresentPasscodeWindowIfNeeded()
        guard let passcodeDatasource = passcodeDatasource else {
            return
        }
        var newPasscode: [Int] = []
        passcodeLockViewController = PasscodeLockViewController(validateCode: { passcode in
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
            self.dismissAnimated(true) {
                completion?(didCancel)
            }
        })
        passcodeLockViewController.cancelButtonEnabled = true
        passcodeView.pinView(passcodeLockViewController.view)
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
        passcodeLockViewController = PasscodeLockViewController(validateCode: { passcode in
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
            self.dismissAnimated(true) {
                completion?(didCancel)
            }
        })
        passcodeLockViewController.cancelButtonEnabled = true
        passcodeView.pinView(passcodeLockViewController.view)
    }
    
    func dismissAnimated(animated: Bool, completion: ((Void) -> (Void))? = nil) {
        let removeView = {
            self.passcodeView.removeFromSuperview()
            self.passcodeView = nil;
            self.passcodeLockViewController = nil;
            completion?()
        }
        if animated {
            passcodeView.fadeOutAnimated(removeView)
        } else {
            removeView()
        }
    }
    
    private func screenshotAndPresentPasscodeWindowIfNeeded() {
        if isShowingPasscode() {
            return
        }
        guard let rootViewController = passcodeDatasource?.rootViewController() else {
            return
        }
        
        passcodeView = PasscodeObstructionView(backgroundView: generateBackgroundView(rootViewController.view))
        rootViewController.view.pinView(passcodeView)
    }
    
    ///Older devices cannot render the blur effect fast enough, for those we return a black UIView instance instead
    private func generateBackgroundView(parentView: UIView) -> UIView {
        let OneKiloByte: UInt64 = 1024
        let OneMegaByte: UInt64 = 1024*OneKiloByte
        let physicalMemoryForBlurredBackground: UInt64 = 512*OneMegaByte
        let memory = NSProcessInfo.processInfo().physicalMemory
        
        if (memory > physicalMemoryForBlurredBackground) {
            let backgroundView = UIImageView(image: parentView.screenShotView())
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            return backgroundView
        } else {
            let backgroundView = UIView(frame: .zero)
            backgroundView.backgroundColor = UIColor.blackColor()
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            return backgroundView
        }
    }
}
