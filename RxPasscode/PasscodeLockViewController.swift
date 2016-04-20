
import UIKit
import RxSwift
import RxCocoa

private let passcodeNumbersRequired: Int = 4

class PasscodeLockViewController: UIViewController {
        
    typealias PasscodeButtonConfig = (number: Int, xOffset: CGFloat, yOffset: CGFloat)
    
    enum PasscodeResponse {
        case Invalid
        case ReEnter
        case EnterNew
        case Accepted
    }
    
    var cancelButtonEnabled = false
    var cancelButton: UIButton!
    var titleLabel: UILabel!
    var passcodeButtons: [PasscodeNumberButton] = []
    var passcodeNumberInputtedViews: [PasscodeNumberInputted] = []
    var passcodeNumbers: Variable<[Int]> = Variable([Int]())
    var disposeBag: DisposeBag = DisposeBag()
    let validateCode: ([Int] -> PasscodeResponse)
    let dismiss: (Bool -> Void)
    var statusBarStyle: UIStatusBarStyle = UIStatusBarStyle.Default
    
    private let titleLabelYOffset: CGFloat = -210
    
    init(validateCode: ([Int] -> PasscodeResponse), dismiss: (Bool -> Void)) {
        self.validateCode = validateCode
        self.dismiss = dismiss
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        //MARK: Layout
        
        titleLabel = UILabel(frame: CGRectZero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = NSLocalizedString("Enter passcode", comment: "")
        titleLabel.textColor = UIColor.whiteColor()
        view.pinCenter(titleLabel, horizontalOffset: 0, verticalOffset:titleLabelYOffset)
        
        if cancelButtonEnabled {
            cancelButton = UIButton(type: .Custom)
            cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), forState: .Normal)
            cancelButton.translatesAutoresizingMaskIntoConstraints = false
            cancelButton.rx_tap.subscribeNext { [weak self] in
                self?.animateDismissal(true)
            }.addDisposableTo(disposeBag)
            view.pinBottomRight(cancelButton, horizontalOffset:-20, verticalOffset:-20)
        }
        
        let passcodeLayoutItems: [PasscodeButtonConfig] = [
            (1, -1, -1), (2, 0, -1), (3, 1, -1),
            (4, -1, 0), (5, 0, 0), (6, 1, 0),
            (7, -1, 1), (8, 0, 1), (9, 1, 1),
            (0, 0, 2)]
        for (number, x, y) in passcodeLayoutItems {
            let button = createButtonWithOffset("\(number)", horizontalOffset: x, verticalOffset: y)
            passcodeButtons.append(button)
            button.rx_tap.subscribeNext { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                if strongSelf.passcodeNumbers.value.count < passcodeNumbersRequired {
                    strongSelf.passcodeNumbers.value.append(number)
                }
            }.addDisposableTo(disposeBag)
        }
        
        let inputOffsets: [CGFloat] = [-1.5, -0.5, 0.5, 1.5]
        for inputOffset in inputOffsets {
            passcodeNumberInputtedViews.append(createInputWithOffset(inputOffset))
        }
        
        //MARK: RX Events
        
        passcodeNumbers.asObservable().subscribeNext { [weak self] numbers in
            guard let strongSelf = self else {
                return
            }

            if numbers.count > 0 {
                strongSelf.passcodeNumberInputtedViews[numbers.count-1].animateToState(.Active)
            } else {
                for view in strongSelf.passcodeNumberInputtedViews {
                    view.animateToState(.Inactive)
                }
            }
        }.addDisposableTo(disposeBag)
        
        passcodeNumbers.asObservable().filter { numbers in
            return numbers.count == passcodeNumbersRequired
        }.throttle(0.1, scheduler: MainScheduler.instance)
        .subscribeNext { [weak self] numbers in
            self?.validatePasscode(numbers)
        }.addDisposableTo(disposeBag)
        
    }
    
    func validatePasscode(numbers: [Int]) {
        switch validateCode(numbers) {
            case .Accepted:
                animateDismissal()
            case .ReEnter:
                titleLabel.text = NSLocalizedString("Re-enter passcode", comment: "")
                passcodeNumbers.value = []
            case .EnterNew:
                titleLabel.text = NSLocalizedString("Enter new passcode", comment: "")
                passcodeNumbers.value = []
            case .Invalid:
                animateIncorrectPasscode()
                passcodeNumbers.value = []
            
        }
    }
    
    //MARK: Events
    
    func highlightNextNumberInputtedView(viewIndex: Int) {
        passcodeNumberInputtedViews[viewIndex].animateToState(.Active)
    }
        
    //MARK: Helpers for button creation and layout
    
    private let horizontalButtonSpacing: CGFloat = 91
    private let verticalButtonSpacing: CGFloat = 91
    private let buttonSize: CGFloat = 80
    private let buttonsCenterYOffset: CGFloat = -20
    
    func createButtonWithOffset(text: String, horizontalOffset: CGFloat, verticalOffset: CGFloat) -> PasscodeNumberButton {
        let button = PasscodeNumberButton(buttonSize: buttonSize)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(text, forState: UIControlState.Normal)
        view.pinCenter(button, horizontalOffset: horizontalOffset*horizontalButtonSpacing, verticalOffset: buttonsCenterYOffset+verticalOffset*verticalButtonSpacing)
        return button
    }
    
    private let inputYOffset: CGFloat = -180
    private let inputXOffset: CGFloat = 22
    private let inputSize: CGFloat = 16
    
    func createInputWithOffset(horizontalOffset: CGFloat) -> PasscodeNumberInputted {
        let input = PasscodeNumberInputted(size: inputSize)
        input.translatesAutoresizingMaskIntoConstraints = false
        view.pinCenter(input, horizontalOffset: horizontalOffset*inputXOffset, verticalOffset: inputYOffset)
        return input
    }
    
}
