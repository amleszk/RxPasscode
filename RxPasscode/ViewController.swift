
import UIKit
import LiveFrost

class ViewController: UIViewController {

    var passcodePresenter: PasscodePresenter!
    
    private lazy var frostView: LFGlassView = {
        let frostView = LFGlassView()
        frostView.translatesAutoresizingMaskIntoConstraints = false
        frostView.blurRadius = 12
        frostView.scaleFactor = 1
        return frostView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.pinView(frostView)
    }
    
    override func viewDidAppear(animated: Bool) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            self.passcodePresenter = PasscodePresenter()
            self.passcodePresenter.presentInKeyWindow()
            
//            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
//            dispatch_after(delayTime, dispatch_get_main_queue()) {
//                self.passcodePresenter.dismiss()
//            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }


}
