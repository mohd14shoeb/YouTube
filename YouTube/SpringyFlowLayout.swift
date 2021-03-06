import UIKit

class SpringyFlowLayout: UICollectionViewFlowLayout {
    var dynamicAnimator: UIDynamicAnimator?
    
    func setup(){
        dynamicAnimator = nil
    }
    override func prepareLayout() {
        super.prepareLayout()
        if dynamicAnimator != nil{
            return
        }
        dynamicAnimator = UIDynamicAnimator(collectionViewLayout: self)
        let contentSize = collectionViewContentSize()
        
        if let items = super.layoutAttributesForElementsInRect(
            CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)) {
                
                for item in items {
                    let spring = UIAttachmentBehavior(item: item, attachedToAnchor: item.center)
                    spring.length = 0
                    spring.damping = 0.5
                    spring.frequency = 0.8
                    dynamicAnimator?.addBehavior(spring)
                }
        }
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return dynamicAnimator?.itemsInRect(rect) as? [UICollectionViewLayoutAttributes] ??
            super.layoutAttributesForElementsInRect(rect)
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return dynamicAnimator?.layoutAttributesForCellAtIndexPath(indexPath) ??
            super.layoutAttributesForItemAtIndexPath(indexPath)
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        if let collectionView = collectionView,
            dynamicAnimator = dynamicAnimator {
                if scrollDirection == .Vertical{
                let delta =  newBounds.origin.y - collectionView.bounds.origin.y
                
                let touchLocation = collectionView.panGestureRecognizer.locationInView(collectionView)
                
                for spring in dynamicAnimator.behaviors {
                    if let spring = spring as? UIAttachmentBehavior,
                        item = spring.items.first as? UICollectionViewLayoutAttributes {
                            
                            // Increase the length of the spring based on how far the item is from the touch location
                            // The farther away the item - the more stretch the spring will be
                            let anchorPoint: CGFloat = spring.anchorPoint.y
                            let distanceFromTouch: CGFloat = fabs(anchorPoint - touchLocation.y)
                            let scrollResistance: CGFloat = distanceFromTouch / 1000
                            
                            var center = item.center
                            center.y += delta * scrollResistance
                            item.center = center
                            
                            dynamicAnimator.updateItemUsingCurrentState(item)
                    }
                    }
                }else if scrollDirection == .Horizontal{
                    let delta =  newBounds.origin.x - collectionView.bounds.origin.x
                    
                    let touchLocation = collectionView.panGestureRecognizer.locationInView(collectionView)
                    
                    for spring in dynamicAnimator.behaviors {
                        if let spring = spring as? UIAttachmentBehavior,
                            item = spring.items.first as? UICollectionViewLayoutAttributes {
                                
                                // Increase the length of the spring based on how far the item is from the touch location
                                // The farther away the item - the more stretch the spring will be
                                let anchorPoint: CGFloat = spring.anchorPoint.x
                                let distanceFromTouch: CGFloat = fabs(anchorPoint - touchLocation.x)
                                let scrollResistance: CGFloat = distanceFromTouch / 1000
                                
                                var center = item.center
                                center.x += delta * scrollResistance
                                item.center = center
                                
                                dynamicAnimator.updateItemUsingCurrentState(item)
                        }
                    }

                }
        }
        
        return true
    }
}
