
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
        view.pinView(frostView)
    }
    
}
