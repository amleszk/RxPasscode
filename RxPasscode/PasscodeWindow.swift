
import UIKit

class PasscodeWindow: UIWindow {
    
    internal lazy var frostView: RxGlassView = {
        let frostView = RxGlassView(frame:CGRect(origin: CGPointZero, size: UIScreen.mainScreen().bounds.size))
        return frostView
    }()
    
    internal lazy var dimmingView: UIView = {
        let dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor.blackColor()
        dimmingView.alpha = 0.25
        return dimmingView
    }()
    
    init(backgroundView: UIView) {
        super.init(frame: UIScreen.mainScreen().bounds)
        pinView(backgroundView)
        pinView(dimmingView)
        pinView(frostView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func fadeInBackgroundAnimated() {
        frostView.fadeInAnimated()
        dimmingView.fadeInAnimated()
    }

    func fadeOutBackgroundAnimated(completion: (Void) -> (Void)) {
        frostView.fadeOutAnimated {
            completion()
        }
        dimmingView.fadeOutAnimated(nil)
    }
}

class HiddenViewController: UIViewController {
    override func viewDidLoad() {
        self.view.hidden = true
    }
}
