//
//  InventoryCell.swift
//  domesticare
//
//  Created by Sayuru Rehan on 2025-04-20
//

import Foundation
import UIKit

class InventoryCell: UICollectionViewCell {
    static let CellTouchOnAnimationDuration = 0.2
    let imageView = UIImageView()
    
    private var _drugImage: UIImage?
    var drugImage: UIImage? {
        get {
            return self._drugImage
        }
        set (newValue) {
            self._drugImage = newValue
            self.imageView.image = self.drugImage
        }
    }
    
    let medicationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemGray6
        self.layer.cornerRadius = 15
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: InventoryCell.CellTouchOnAnimationDuration) {
            self.imageView.alpha = 0.5
        }
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: InventoryCell.CellTouchOnAnimationDuration) {
            self.imageView.alpha = 1
        }
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: InventoryCell.CellTouchOnAnimationDuration) {
            self.imageView.alpha = 1
        }
        super.touchesCancelled(touches, with: event)
    }
    
    func setupView() {
        self.layer.shadowColor = UIColor.systemGray.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 2
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        
        addSubview(imageView)
        addSubview(medicationLabel)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20),
            imageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -60)
        ])
        NSLayoutConstraint.activate([
            medicationLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            medicationLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20),
            medicationLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20),
            medicationLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20)
        ])
        
    }
}
