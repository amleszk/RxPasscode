
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
    
    internal var passcodeView: PasscodeObstructionView!
    internal var passcodeLockViewController: PasscodeLockViewController!
    internal var disposeBag: DisposeBag = DisposeBag()
    
    var passcodeDatasource: PasscodeDatasource?
    
    class var sharedInstance: PasscodePresenter {
        return passcodePresenterSharedInstance
    }
    
    override init() {
        super.init()
    }
    
    func hookApplicationWillResignActive() {
        NSNotificationCenter.defaultCenter().rx_notification(UIApplicationDidEnterBackgroundNotification).subscribeNext { _ in
            PasscodePresenter.sharedInstance.presentWithBlurBackground()
        }.addDisposableTo(disposeBag)
        NSNotificationCenter.defaultCenter().rx_notification(UIApplicationWillEnterForegroundNotification).subscribeNext { _ in
            if !PasscodePresenter.sharedInstance.isShowingPasscode() {
                PasscodePresenter.sharedInstance.presentWithValidatePasscode()
            }
        }.addDisposableTo(disposeBag)
    }
    
    func isShowingPasscode() -> Bool {
        return passcodeLockViewController != nil
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
    
    internal func screenshotAndPresentPasscodeObstructionIfNeeded() {
        if passcodeView?.window != nil {
            return
        }
        guard let rootViewController = passcodeDatasource?.rootViewController() else {
            return
        }
        
        passcodeView = PasscodeObstructionView(backgroundView: generateBackgroundView(rootViewController.view))
        passcodeView.translatesAutoresizingMaskIntoConstraints = false
        rootViewController.view.pinView(passcodeView)
    }
    
    ///Older devices cannot render the blur effect fast enough, for those we return a black UIView instance instead
    private func generateBackgroundView(parentView: UIView) -> UIView {
        let OneKiloByte: UInt64 = 1024
        let OneMegaByte: UInt64 = 1024*OneKiloByte
        let physicalMemoryForBlurredBackground: UInt64 = 512*OneMegaByte
        let memory = NSProcessInfo.processInfo().physicalMemory
        
        if (memory > physicalMemoryForBlurredBackground) {
            let backgroundView = UIImageView(image: parentView.imageRepresentation())
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
