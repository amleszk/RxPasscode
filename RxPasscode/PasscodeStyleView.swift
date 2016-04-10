
import UIKit

enum PasscodeStyleViewState {
    case Active
    case Inactive
}

protocol PasscodeStyleView: class {
    var borderColor: UIColor { get }
    var borderRadius: CGFloat { get }
    var highlightBackgroundColor: UIColor { get }
    var defaultBackgroundColor: UIColor { get }
    var intrinsicSize: CGSize  { get }
    var displayedState: PasscodeStyleViewState  { get set }
}

extension PasscodeStyleView where Self: UIView {
    
    internal func setupViewBorder() {
        layer.borderWidth = 1
        layer.cornerRadius = borderRadius
        layer.borderColor = borderColor.CGColor
    }
    
    func animateToState(state: PasscodeStyleViewState) {
        switch state {
        case .Active:
            animateBackgroundColor(highlightBackgroundColor, duration:0.1, delay: 0.0)
        case .Inactive:
            animateBackgroundColor(defaultBackgroundColor, duration:0.5, delay: 0.15)
        }
        displayedState = state
    }
    
    private func animateBackgroundColor(color: UIColor, duration: NSTimeInterval, delay: NSTimeInterval) {
        UIView.animateWithDuration(
            duration,
            delay: delay,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0.5,
            options: [.AllowUserInteraction, .BeginFromCurrentState],
            animations: {
                self.backgroundColor = color
            },
            completion: nil)
    }
    
}

