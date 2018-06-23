//
//  ShadowView.swift
//  places
//

import Foundation
import UIKit

class ShadowView: UIView {
    
    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }
    
    private func setupShadow() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 5
        let shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0);
        self.layer.shadowOpacity = 0.7
        self.layer.shadowPath = shadowPath.cgPath
    }
}
