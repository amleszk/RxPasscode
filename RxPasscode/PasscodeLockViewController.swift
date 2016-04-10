
import UIKit
import LiveFrost

class PasscodeLockViewController: UIViewController {
    
    let backgroundView: UIView
    private lazy var frostView: LFGlassView = {
        let frostView = LFGlassView()
        frostView.translatesAutoresizingMaskIntoConstraints = false
        frostView.blurRadius = 11
        frostView.scaleFactor = 1
        return frostView
    }()
    
    private lazy var dimmingView: UIView = {
        let dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor.blackColor()
        dimmingView.alpha = 0.25
        return dimmingView
    }()
    
    
    init(backgroundView: UIView) {
        self.backgroundView = backgroundView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.pinView(backgroundView)
        view.pinView(dimmingView)
        view.pinView(frostView)
        
        let offsets: [(String, CGFloat,CGFloat)] = [
            ("1", -1, -1), ("2", 0, -1), ("3", 1, -1),
            ("4", -1, 0), ("5", 0, 0), ("6", 1, 0),
            ("7", -1, 1), ("8", 0, 1), ("9", 1, 1),
            ("0", 0, 2)]
        for (text, x, y) in offsets {
            createButtonWithOffset(text, horizontalOffset: x, verticalOffset: y)
        }
    }
    
    private let horizontalButtonSpacing: CGFloat = 95
    private let verticalButtonSpacing: CGFloat = 95
    private let buttonSize: CGFloat = 80
    private let buttonsCenterYOffset: CGFloat = -20
    
    func createButtonWithOffset(text: String, horizontalOffset: CGFloat, verticalOffset: CGFloat) {
        let button = PasscodeNumberButton(buttonSize: buttonSize)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(text, forState: UIControlState.Normal)
        view.pinCenter(button, horizontalOffset: horizontalOffset*horizontalButtonSpacing, verticalOffset: buttonsCenterYOffset+verticalOffset*verticalButtonSpacing)
    }
    
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
}
