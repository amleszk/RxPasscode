
import UIKit

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
