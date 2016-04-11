
import UIKit

private let blurCallbackInterval: NSTimeInterval = 0.05
private let blurCallbackBlurReductionSpeed: CGFloat = 1.5
private let invalidShakeXOffset: CGFloat = -40

extension PasscodeLockViewController {
    
    func animateIncorrectPasscode() {
        for view in self.passcodeNumberInputtedViews {
            view.transform = CGAffineTransformMakeTranslation(invalidShakeXOffset, 0)
        }
        
        UIView.animateWithDuration(
            0.5,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 0,
            options: [],
            animations: {
                for view in self.passcodeNumberInputtedViews {
                    view.transform = CGAffineTransformIdentity
                }
            },
            completion: nil)
    }
    
    func animateDismissal() {
        
        let timer = NSTimer(timeInterval: blurCallbackInterval, target: self, selector: #selector(PasscodeLockViewController.reduceFrostingBlurRadius), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        
        UIView.animateWithDuration(
            0.3,
            delay: 0,
            options: [.CurveEaseInOut],
            animations: {
                for view in self.passcodeNumberInputtedViews {
                    view.alpha = 0
                }
                for view in self.passcodeButtons {
                    view.alpha = 0
                }
                self.titleLabel.alpha = 0
                self.dimmingView.alpha = 0
            },
            completion: nil)
        
        
    }
    
    func reduceFrostingBlurRadius(timer: NSTimer) {
        frostView.blurRadius = max(0,frostView.blurRadius - blurCallbackBlurReductionSpeed)
        frostView.blurOnceIfPossible()
        if frostView.blurRadius == 0 {
            timer.invalidate()
            self.unlocked()
        }
    }
}