
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
    
    func imageRepresentation() -> UIImage? {
        // Create a graphics context with the target size
        // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
        // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
        let imageSize = bounds.size
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        // -renderInContext: renders in the coordinate space of the layer,
        // so we must first apply the layer's geometry to the graphics context
        CGContextSaveGState(context)
        // Center the context around the view's anchor point
        CGContextTranslateCTM(context, center.x, center.y)
        // Apply the view's transform about the anchor point
        CGContextConcatCTM(context, transform)
        // Offset by the portion of the bounds left of and above the anchor point
        CGContextTranslateCTM(context,
                              -bounds.size.width * layer.anchorPoint.x,
                              -bounds.size.height * layer.anchorPoint.y)
        
        // Render the layer hierarchy to the current context
        layer.renderInContext(context)
        
        // Restore the context
        CGContextRestoreGState(context);
        
        // Retrieve the screenshot image
        let image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return image;
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
