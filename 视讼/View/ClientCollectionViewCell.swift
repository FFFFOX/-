//
//  ClientCollectionViewCell.swift
//  视讼
//
//  Created by KlausZhang on 2020/7/28.
//  Copyright © 2020 KlausZhang. All rights reserved.
//

import UIKit

class ClientCollectionViewCell: UICollectionViewCell,UITextFieldDelegate {

    @IBOutlet weak var divider: UILabel!
    @IBOutlet weak var clientDetailsTitle: UILabel!
    @IBOutlet weak var clientImage: UIImageView!
    @IBOutlet weak var nameImage: UIImageView!
    @IBOutlet weak var peopleImage: UIImageView!
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var peopleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    var nameTextField: UITextField = UITextField()
    var peopleTextField: UITextField = UITextField()
    var addressTextField: UITextField = UITextField()

    @IBOutlet weak var confirmBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        nameTextField = UITextField(frame: CGRect(x: 189, y: 100, width: 285, height: 34))
        setupCornerRadius(view: nameTextField, number: 5)
        nameTextField.layer.borderColor = #colorLiteral(red: 0.7215686275, green: 0.7216144204, blue: 0.7214741111, alpha: 0.1976669521)
        nameTextField.layer.borderWidth = 1
        nameTextField.placeholder = "请输入当事人姓名"
        addSubview(nameTextField)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint.init(item: nameTextField, attribute: .top, relatedBy: .equal, toItem: divider, attribute: .top, multiplier: 1, constant: 30),
            NSLayoutConstraint.init(item: nameTextField, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 189),
            NSLayoutConstraint.init(item: nameTextField, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -30),
            NSLayoutConstraint.init(item: nameTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute:.notAnAttribute, multiplier: 1, constant: 34)
        ])
//        peopleTextField = UITextField(frame: CGRect(x: 189, y: 143, width: 285, height: 34))
        setupCornerRadius(view: peopleTextField, number: 5)
        peopleTextField.layer.borderWidth = 1
        peopleTextField.layer.borderColor = #colorLiteral(red: 0.7215686275, green: 0.7216144204, blue: 0.7214741111, alpha: 0.1976669521)
        peopleTextField.placeholder = "请输入民族"
        addSubview(peopleTextField)
        peopleTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint.init(item: peopleTextField, attribute: .top, relatedBy: .equal, toItem: divider, attribute: .top, multiplier: 1, constant: 73),
            NSLayoutConstraint.init(item: peopleTextField, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 189),
            NSLayoutConstraint.init(item: peopleTextField, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -30),
            NSLayoutConstraint.init(item: peopleTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute:.notAnAttribute, multiplier: 1, constant: 34)
        ])
//        addressTextField = UITextField(frame: CGRect(x: 189, y: 186, width: 285, height: 34))
        setupCornerRadius(view: addressTextField, number: 5)
        addressTextField.layer.borderWidth = 1
        addressTextField.layer.borderColor = #colorLiteral(red: 0.7215686275, green: 0.7216144204, blue: 0.7214741111, alpha: 0.1976669521)
        addressTextField.placeholder = "请输入地址"
        addSubview(addressTextField)
        addressTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint.init(item: addressTextField, attribute: .top, relatedBy: .equal, toItem: divider, attribute: .top, multiplier: 1, constant: 116),
            NSLayoutConstraint.init(item: addressTextField, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 189),
            NSLayoutConstraint.init(item: addressTextField, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -30),
            NSLayoutConstraint.init(item: addressTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute:.notAnAttribute, multiplier: 1, constant: 34)
        ])
        nameTextField.clearButtonMode = UITextField.ViewMode.whileEditing
        
        peopleTextField.clearButtonMode = UITextField.ViewMode.whileEditing
        
        addressTextField.clearButtonMode = UITextField.ViewMode.whileEditing
    }

}
