//
//  MyCollectionViewLayout.swift
//  places
//

import UIKit

class MyCollectionViewLayout: UICollectionViewFlowLayout {
    
    override func awakeFromNib() {
        
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var newContentOffset:CGPoint = CGPoint.init(x: 0.0, y: 0.0)
        let rawPageValue = CGFloat((collectionView?.contentOffset.x)! / pageWidth!)
        let currentPage: CGFloat = (velocity.x > 0.0) ? floor(rawPageValue) : ceil(rawPageValue)
        let nextPage: CGFloat = (velocity.x > 0.0) ? ceil(rawPageValue) : floor(rawPageValue)
        let pannedLessThanAPage: Bool = fabs(1 + currentPage - rawPageValue) > 0.5
        let flicked: Bool = fabs(velocity.x) > 0.0
        if pannedLessThanAPage && flicked {
            newContentOffset.x = nextPage * pageWidth!
        }
        else {
            newContentOffset.x = round(rawPageValue) * pageWidth!
        }
        return newContentOffset
    }
    
    var pageWidth: CGFloat? {
        return itemSize.width + minimumLineSpacing
    }
}

