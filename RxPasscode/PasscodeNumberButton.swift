
import UIKit

class PasscodeSignButton: UIButton {
    
    var borderColor: UIColor = UIColor.whiteColor() {
        didSet {
            setupView()
        }
    }
    
    let borderRadius: CGFloat
    let buttonSize: CGSize
    
    var highlightBackgroundColor: UIColor = UIColor.clearColor() {
        didSet {
            setupView()
        }
    }
    
    init(buttonSize: CGFloat) {
        self.buttonSize = CGSizeMake(buttonSize, buttonSize)
        self.borderRadius = floor(buttonSize/2)
        super.init(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        setupView()
        setupActions()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func intrinsicContentSize() -> CGSize {
        return buttonSize
    }
    
    private var defaultBackgroundColor = UIColor.clearColor()
    
    private func setupView() {        
        layer.borderWidth = 1
        layer.cornerRadius = borderRadius
        layer.borderColor = borderColor.CGColor
    }
    
    private func setupActions() {
        
        addTarget(self, action: #selector(PasscodeSignButton.handleTouchDown), forControlEvents: .TouchDown)
        addTarget(self, action: #selector(PasscodeSignButton.handleTouchUp), forControlEvents: [.TouchUpInside, .TouchDragOutside, .TouchCancel])
    }
    
    func handleTouchDown() {
        
        animateBackgroundColor(highlightBackgroundColor)
    }
    
    func handleTouchUp() {
        
        animateBackgroundColor(defaultBackgroundColor)
    }
    
    private func animateBackgroundColor(color: UIColor) {
        
        UIView.animateWithDuration(
            0.3,
            delay: 0.0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0.0,
            options: [.AllowUserInteraction, .BeginFromCurrentState],
            animations: {
                self.backgroundColor = color
            },
            completion: nil
        )
    }
}
