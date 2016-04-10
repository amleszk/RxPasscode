
import UIKit
import LiveFrost

class ViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.pinView(frostView)
    }
    
    override func viewDidAppear(animated: Bool) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            PasscodePresenter.sharedInstance.presentInKeyWindow()
            
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
