//
//  DocumentsTableViewCell.swift
//  视讼
//
//  Created by KlausZhang on 2020/8/4.
//  Copyright © 2020 KlausZhang. All rights reserved.
//

import UIKit

class DocumentsTableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnail: UIImageView!
    
    @IBOutlet weak var createTime: UILabel!
    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
