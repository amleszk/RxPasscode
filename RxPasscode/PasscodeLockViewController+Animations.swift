
import UIKit

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
        
        frostView.unBlurAnimated {
            self.unlocked()
        }
        
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
}

