//
//  CardCVC.swift
//  places
//

import UIKit
import Kingfisher

class CardCVC: UICollectionViewCell {

    @IBOutlet weak var placeTitleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.containerView.layer.cornerRadius = 5
    }
    
    func setupWithPlace(place:Place)  {
        self.placeTitleLabel.text = place.name
        self.backgroundImageView.kf.setImage(with: URL.init(string: place.imageUrl)!)
    }
}
