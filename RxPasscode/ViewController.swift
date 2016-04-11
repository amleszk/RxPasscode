
import UIKit
import RxSwift
import RxCocoa


class ViewController: UIViewController {
    
    
    @IBOutlet weak var validatePasscodeButton: UIButton!
    @IBOutlet weak var newPasscodeButton: UIButton!
    @IBOutlet weak var changePasscodeButton: UIButton!

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        validatePasscodeButton.rx_tap.subscribeNext {
            PasscodePresenter.sharedInstance.presentWithValidatePasscode()
        }.addDisposableTo(disposeBag)
        
        newPasscodeButton.rx_tap.subscribeNext {
            PasscodePresenter.sharedInstance.presentWithNewPasscode()
        }.addDisposableTo(disposeBag)

        changePasscodeButton.rx_tap.subscribeNext {
            PasscodePresenter.sharedInstance.presentWithChangePasscode()
        }.addDisposableTo(disposeBag)

    }

}
