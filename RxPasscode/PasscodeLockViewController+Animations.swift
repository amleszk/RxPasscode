
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
    
}

