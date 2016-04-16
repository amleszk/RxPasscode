
import Foundation
import LiveFrost

private let blurCallbackInterval: NSTimeInterval = 0.05
private let blurAnimationTime: NSTimeInterval = 0.3

class RxGlassView : LFGlassView {
    
    var startingBlurRadius: CGFloat = 0
    var endingTime: NSTimeInterval = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        blurRadius = 15
        scaleFactor = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var fadeoutCompletion: (Void -> Void)?
    
    func fadeOutAnimated(completion: (Void -> Void)) {
        UIView.animateWithDuration(blurAnimationTime, animations: {
            self.alpha = 0
        }, completion: { _ in
            completion()
        })
    }
    
    func unBlurAnimated(completion: (Void -> Void)) {
        UIView.animateWithDuration(blurAnimationTime) {
            self.alpha = 0
        }
        
        liveBlurring = false
        fadeoutCompletion = completion
        startingBlurRadius = blurRadius
        endingTime = NSDate().timeIntervalSince1970+blurAnimationTime
        let timer = NSTimer(timeInterval: blurCallbackInterval, target: self, selector: #selector(RxGlassView.reduceFrostingBlurRadius), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    func reduceFrostingBlurRadius(timer: NSTimer) {
        let percentageComplete = CGFloat((endingTime-NSDate().timeIntervalSince1970)/blurAnimationTime)
        blurRadius = max(0,startingBlurRadius*percentageComplete)
        self.alpha = percentageComplete
        blurOnceIfPossible()
        if blurRadius == 0 {
            timer.invalidate()
            fadeoutCompletion?()
            fadeoutCompletion = nil
        }
    }
}
