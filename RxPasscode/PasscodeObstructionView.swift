
import UIKit

class PasscodeObstructionView: UIView {
    
    var frostView: UIVisualEffectView?
    
    init(backgroundView: UIView) {
        if (backgroundView is UIImageView) {
            frostView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
            frostView!.translatesAutoresizingMaskIntoConstraints = false
            backgroundView.pinView(frostView!)
        }
        
        super.init(frame: UIScreen.mainScreen().bounds)
        pinView(backgroundView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
