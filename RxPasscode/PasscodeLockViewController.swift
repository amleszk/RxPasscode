
import UIKit
import LiveFrost
import RxSwift
import RxCocoa

private let passcodeNumbersRequired: Int = 4

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
    
    typealias PasscodeLayoutItem = (number: Int, xOffset: CGFloat, yOffset: CGFloat)
    
    var passcodeButtons: [PasscodeNumberButton] = []
    var passcodeNumberInputtedViews: [PasscodeNumberInputted] = []
    var passcodeNumbers: Variable<[Int]> = Variable([Int]())
    var disposeBag: DisposeBag = DisposeBag()
    let validateCode: ([Int] -> Bool)
    let unlocked: (Void -> Void)
    
    init(backgroundView: UIView, validateCode: ([Int] -> Bool), unlocked: (Void -> Void)) {
        self.backgroundView = backgroundView
        self.validateCode = validateCode
        self.unlocked = unlocked
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
        
        let passcodeLayoutItems: [PasscodeLayoutItem] = [
            (1, -1, -1), (2, 0, -1), (3, 1, -1),
            (4, -1, 0), (5, 0, 0), (6, 1, 0),
            (7, -1, 1), (8, 0, 1), (9, 1, 1),
            (0, 0, 2)]
        for (number, x, y) in passcodeLayoutItems {
            let button = createButtonWithOffset("\(number)", horizontalOffset: x, verticalOffset: y)
            passcodeButtons.append(button)
            button.rx_tap.subscribeNext {
                if self.passcodeNumbers.value.count < passcodeNumbersRequired {
                    self.passcodeNumbers.value.append(number)
                }
            }.addDisposableTo(disposeBag)
        }
        
        let inputOffsets: [CGFloat] = [-1.5, -0.5, 0.5, 1.5]
        for inputOffset in inputOffsets {
            passcodeNumberInputtedViews.append(createInputWithOffset(inputOffset))
        }
        
        passcodeNumbers.asObservable().subscribeNext { numbers in
            if numbers.count > 0 {
                self.passcodeNumberInputtedViews[numbers.count-1].animateToState(.Active)
            } else {
                for view in self.passcodeNumberInputtedViews {
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
        if validateCode(numbers) {
            animateDismissal()
        } else {
            animateIncorrectPasscode()
            passcodeNumbers.value = []
        }
    }
    
    //MARK: Events
    
    func highlightNextNumberInputtedView(viewIndex: Int) {
        passcodeNumberInputtedViews[viewIndex].animateToState(.Active)
    }
    
    func animateIncorrectPasscode() {
        for view in self.passcodeNumberInputtedViews {
            view.transform = CGAffineTransformMakeTranslation(-40, 0)
        }

        UIView.animateWithDuration(
            0.5,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 0,
            options: [],
            animations: {
                for view in self.passcodeNumberInputtedViews {
                    view.transform = CGAffineTransformIdentity
                }
            },
            completion: nil)
    }
    
    private let blurCallbackInterval: NSTimeInterval = 0.01
    private let blurCallbackTrailoff: CGFloat = 0.5
    
    func animateDismissal() {
        frostView.liveBlurring = true
        
        let timer = NSTimer(timeInterval: blurCallbackInterval, target: self, selector: #selector(PasscodeLockViewController.reduceFrostingBlurRadius), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)

        UIView.animateWithDuration(
            1.0,
            delay: 0,
            options: [.CurveEaseInOut],
            animations: {
                for view in self.passcodeNumberInputtedViews {
                    view.alpha = 0
                }
                for view in self.passcodeButtons {
                    view.alpha = 0
                }
                self.dimmingView.alpha = 0
            },
            completion: { _ in
                timer.invalidate()
                self.unlocked()
        })
        
    }
    
    func reduceFrostingBlurRadius() {
        frostView.blurRadius = frostView.blurRadius - blurCallbackTrailoff
    }
    
    //MARK: Sub view creation and layout
    
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
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
}
