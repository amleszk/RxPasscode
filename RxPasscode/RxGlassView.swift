
import Foundation
import LiveFrost

private let blurCallbackInterval: NSTimeInterval = 0.05
private let blurCallbackBlurReductionSpeed: CGFloat = 1.5


class RxGlassView : LFGlassView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        blurRadius = 15
        scaleFactor = 1
        liveBlurring = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var fadeoutCompletion: (Void -> Void)?
    
    func unBlurAnimated(completion: (Void -> Void)) {
        fadeoutCompletion = completion
        let timer = NSTimer(timeInterval: blurCallbackInterval, target: self, selector: #selector(RxGlassView.reduceFrostingBlurRadius), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    func reduceFrostingBlurRadius(timer: NSTimer) {
        blurRadius = max(0,blurRadius - blurCallbackBlurReductionSpeed)
        blurOnceIfPossible()
        if blurRadius == 0 {
            timer.invalidate()
            fadeoutCompletion?()
            fadeoutCompletion = nil
        }
    }

    
}
