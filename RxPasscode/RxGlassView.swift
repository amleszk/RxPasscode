
import Foundation
import LiveFrost

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
}
