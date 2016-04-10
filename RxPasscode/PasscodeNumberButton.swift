
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
    
    private func setupViewBorder() {
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

class PasscodeNumberButton: UIButton, PasscodeStyleView {
    
    var borderColor: UIColor = UIColor.whiteColor()
    var highlightBackgroundColor: UIColor = UIColor(white: 0.9, alpha: 0.8)
    var defaultBackgroundColor = UIColor.clearColor()
    let borderRadius: CGFloat
    let intrinsicSize: CGSize
    var displayedState: PasscodeStyleViewState = .Inactive
    
    init(buttonSize: CGFloat) {
        self.intrinsicSize = CGSizeMake(buttonSize, buttonSize)
        self.borderRadius = floor(buttonSize/2)
        super.init(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        setupViewBorder()
        setupActions()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func intrinsicContentSize() -> CGSize {
        return intrinsicSize
    }
    
    private func setupActions() {
        addTarget(self, action: #selector(PasscodeNumberButton.handleTouchDown), forControlEvents: .TouchDown)
        addTarget(self, action: #selector(PasscodeNumberButton.handleTouchUp), forControlEvents: [.TouchUpInside, .TouchDragOutside, .TouchCancel])
    }
    
    internal func handleTouchDown() {
        animateToState(.Active)
    }
    
    internal func handleTouchUp() {
        animateToState(.Inactive)
    }
}

class PasscodeNumberInputted: UIView, PasscodeStyleView {

    var borderColor: UIColor = UIColor.whiteColor()
    var highlightBackgroundColor: UIColor = UIColor(white: 0.9, alpha: 0.8)
    var defaultBackgroundColor = UIColor.clearColor()
    let borderRadius: CGFloat
    let intrinsicSize: CGSize
    var displayedState: PasscodeStyleViewState = .Inactive
    
    init(size: CGFloat) {
        self.intrinsicSize = CGSizeMake(size, size)
        self.borderRadius = floor(size/2)
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        setupViewBorder()
    }
    
    override func intrinsicContentSize() -> CGSize {
        return intrinsicSize
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
