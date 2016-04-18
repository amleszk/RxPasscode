
import UIKit

extension UIView {
    
    typealias PinConstraints = (left: NSLayoutConstraint, right: NSLayoutConstraint, top: NSLayoutConstraint, bottom: NSLayoutConstraint)
    
    func pinView(subview: UIView) -> PinConstraints {
        addSubview(subview)
        
        let left = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0)
        addConstraint(left)
        let right = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0)
        addConstraint(right)
        let top = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)
        addConstraint(top)
        let bottom = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        addConstraint(bottom)
        
        return (left: left, right: right, top: top, bottom: bottom)
    }
    
    typealias CenterConstraints = (x: NSLayoutConstraint, y: NSLayoutConstraint)
    
    func pinCenter(subview: UIView, horizontalOffset: CGFloat, verticalOffset: CGFloat) -> CenterConstraints {
        addSubview(subview)
        
        let x = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: horizontalOffset)
        addConstraint(x)
        let y = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: verticalOffset)
        addConstraint(y)
        
        return (x,y)
    }
    
    func pinBottomRight(subview: UIView, horizontalOffset: CGFloat, verticalOffset: CGFloat) {
        addSubview(subview)
        let right = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: horizontalOffset)
        addConstraint(right)
        let bottom = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: verticalOffset)
        addConstraint(bottom)
    }
    
    func screenShotView() -> UIImage {
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return screenshot
    }
    
    func fadeInAnimated() {
        self.alpha = 0
        UIView.animateWithDuration(
            0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0.5,
            options: [.AllowUserInteraction, .BeginFromCurrentState],
            animations: {
                self.alpha = 1
            },
            completion: nil)
    }
    
    func fadeOutAnimated(completion: (Void -> Void)?) {
        UIView.animateWithDuration(0.3, animations: {
            self.alpha = 0
            }, completion: { _ in
                completion?()
        })
    }
}
