//
//  RelationshipCollectionViewCell.swift
//  视讼
//
//  Created by KlausZhang on 2020/7/28.
//  Copyright © 2020 KlausZhang. All rights reserved.
//

import UIKit
protocol  RelationshipCollectionViewCellDelegate: class {
    func updateLayout(_ cell: RelationshipCollectionViewCell, with newSize: CGSize)
}
class RelationshipCollectionViewCell: UICollectionViewCell {
    weak var delegate: RelationshipCollectionViewCellDelegate?
    @IBOutlet weak var divider: UILabel!
    @IBOutlet weak var relationshipLabel: UILabel!
    @IBOutlet weak var relationshipImage: UIImageView!
    lazy var textView: CustomTextViewForRelationship! =  {
        //        let textView = CustomTextView(frame: CGRect(x: 30, y: 105, width: 500, height: 120))
        let textView = CustomTextViewForRelationship()
        
        textView.customDelegate = self
        return textView
    }()
    @IBOutlet weak var confirmBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textView.layer.borderWidth = 1
        textView.layer.borderColor = #colorLiteral(red: 0.7215686275, green: 0.7216144204, blue: 0.7214741111, alpha: 1)
        textView.font = UIFont.systemFont(ofSize: 20)
        setupCornerRadius(view: textView, number: 5)
        addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint.init(item: textView!, attribute: .top, relatedBy: .equal, toItem: divider, attribute: .top, multiplier: 1, constant: 30),
            NSLayoutConstraint.init(item: textView!, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 30),
            NSLayoutConstraint.init(item: textView!, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -30),
            NSLayoutConstraint.init(item: textView!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute:.bottom, multiplier: 1, constant: -10)
        ])
    }
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        UIView.animate(withDuration: 0.5) {
            self.layoutIfNeeded()
        }
    }
    
    
    
}
// MARK: - CustomTextView Delegate
extension RelationshipCollectionViewCell: CustomTextViewForRelationshipDelegate {
    func updateFrame(_ textView: UITextView) {
        delegate?.updateLayout(self, with: textView.contentSize)
    }
}
// MARK: - CustomTextView
protocol CustomTextViewForRelationshipDelegate: class {
    func updateFrame(_ textView: UITextView)
}

class CustomTextViewForRelationship: UITextView {
    weak var customDelegate: CustomTextViewForRelationshipDelegate?
    
    override var contentSize: CGSize {
        didSet { customDelegate?.updateFrame(self) }
    }
}
