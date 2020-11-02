//
//  TimeAxisCollectionViewCell.swift
//  视讼
//
//  Created by KlausZhang on 2020/7/28.
//  Copyright © 2020 KlausZhang. All rights reserved.
//

import UIKit
protocol TimeAxisCollectionViewCellDelegate: class {
    func updateLayout(_ cell: TimeAxisCollectionViewCell, with newSize: CGSize)
}
class TimeAxisCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var timeAxisLabel: UILabel!
    @IBOutlet weak var timeAxisImage: UIImageView!
    weak var delegate: TimeAxisCollectionViewCellDelegate?
    @IBOutlet weak var divider: UILabel!
    @IBOutlet weak var confirmBtn: UIButton!
    lazy var textView: CustomTextViewForTimeAxis! =  {
        let textView = CustomTextViewForTimeAxis()
        textView.customDelegate = self
        return textView
    }()

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
extension TimeAxisCollectionViewCell: CustomTextViewForTimeAxisDelegate {
    func updateFrame(_ textView: UITextView) {
        delegate?.updateLayout(self, with: textView.contentSize)
    }
}
// MARK: - CustomTextView
protocol CustomTextViewForTimeAxisDelegate: class {
    func updateFrame(_ textView: UITextView)
}

class CustomTextViewForTimeAxis: UITextView {
    weak var customDelegate: CustomTextViewForTimeAxisDelegate?
    
    override var contentSize: CGSize {
        didSet { customDelegate?.updateFrame(self) }
    }
}

