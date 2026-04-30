//
//  ImagesListCell.swift
//  ImageFeed
//
//
import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    weak var delegate: ImagesListCellDelegate?
    
    private var gradientLayer: CAGradientLayer?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        removeGradient()
    }
    
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked(_ isLiked: Bool){
        if isLiked{
            likeButton.setImage(UIImage(resource: .active), for: .normal)
        }
        else{
            likeButton.setImage(UIImage(resource: .noActive), for: .normal)
        }
    }
    
    func addGradient() {
            removeGradient()

            let gradient = CAGradientLayer()
            gradient.frame = cellImage.bounds
            gradient.locations = [0, 0.1, 0.3]
            gradient.colors = [
                UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
                UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
                UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
            ]
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
            gradient.cornerRadius = 16
            gradient.masksToBounds = true

            let animation = CABasicAnimation(keyPath: "locations")
            animation.duration = 1.0
            animation.repeatCount = .infinity
            animation.fromValue = [0, 0.1, 0.3]
            animation.toValue = [0, 0.8, 1]

            gradient.add(animation, forKey: "locationsChange")

            cellImage.layer.addSublayer(gradient)
            gradientLayer = gradient
        }

        func removeGradient() {
            gradientLayer?.removeFromSuperlayer()
            gradientLayer = nil
        }
}
