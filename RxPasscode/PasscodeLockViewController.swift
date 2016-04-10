
import UIKit
import LiveFrost
import RxSwift
import RxCocoa

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
    
    var passcodeNumberInputtedViews: [PasscodeNumberInputted] = []
    var passcodeNumbers: [Int] = []
    var disposeBag: DisposeBag = DisposeBag()
    let completion: (Void -> Void)
    
    init(backgroundView: UIView, completion: (Void -> Void)) {
        self.backgroundView = backgroundView
        self.completion = completion
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
            button.rx_tap.subscribeNext({
                self.passcodeNumbers.append(number)
                if self.passcodeNumbers.count == 4 {
                    self.completion()
                }
                self.incrementNumbersInputted()
            })
            .addDisposableTo(disposeBag)
        }

        let inputOffsets: [CGFloat] = [-1.5, -0.5, 0.5, 1.5]
        for inputOffset in inputOffsets {
            passcodeNumberInputtedViews.append(createInputWithOffset(inputOffset))
        }
    }
    
    //MARK: Events
    
    func incrementNumbersInputted() {
        let nextViewToSetActive = passcodeNumberInputtedViews.filter { (view: PasscodeNumberInputted) -> Bool in
            return view.displayedState == .Inactive
        }.first
        nextViewToSetActive?.animateToState(.Active)
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
