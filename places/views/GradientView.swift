//
//  GradientView.swift
//  places
//

import Foundation
import UIKit

class GradientViewFromBottom: UIView {
    
    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let gradientLayer = self.layer as! CAGradientLayer
        gradientLayer.colors = [
            UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0).cgColor,
            UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7).cgColor
        ]
    }
}
