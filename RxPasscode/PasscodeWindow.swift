
import UIKit

class PasscodeWindow: UIWindow {
    
    let frostView: UIVisualEffectView
    
    init(backgroundView: UIView) {
        frostView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        frostView.translatesAutoresizingMaskIntoConstraints = false
        super.init(frame: UIScreen.mainScreen().bounds)
        pinView(backgroundView)
        backgroundView.pinView(frostView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func fadeInBackgroundAnimated() {
        frostView.fadeInAnimated()
    }

    func fadeOutBackgroundAnimated(completion: (Void) -> (Void)) {
        frostView.fadeOutAnimated {
            completion()
        }
    }
}

class HiddenViewController: UIViewController {
    override func viewDidLoad() {
        self.view.hidden = true
    }
}
