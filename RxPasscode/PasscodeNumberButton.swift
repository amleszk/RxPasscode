
import UIKit

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
