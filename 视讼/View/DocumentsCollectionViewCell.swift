//
//  DocumentsCollectionViewCell.swift
//  视讼
//
//  Created by KlausZhang on 2020/7/27.
//  Copyright © 2020 KlausZhang. All rights reserved.
//

import UIKit

class DocumentsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
    
    @IBOutlet weak var titleOfDocument: UILabel!
    @IBOutlet weak var highlightIndicator: UIView!
    @IBOutlet weak var selectIndicator: UIImageView!
    @IBOutlet weak var createTime: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        //tempUrl = "img/#.jpg"
//        let docPath = File.getUserFilePath()
//        let tempUrl = "\(name).png"
//        print(tempUrl)
//        let file = docPath.appendingPathComponent(tempUrl)
//        let imgData = try! Data.init(contentsOf: file)
//        thumbnail.contentMode = .scaleAspectFill
//        thumbnail.image = UIImage(data: imgData)
    }
//    override func prepareForReuse() {
//        titleOfDocument.text = topic.last
    //
    override var isSelected: Bool {
        didSet {
            highlightIndicator.isHidden = !isSelected
            selectIndicator.isHidden = !isSelected
        }
    }
    override var isHighlighted: Bool {
        didSet {
             highlightIndicator.isHidden = !isHighlighted
        }
    }
}
class File {
    //获取用户路径
    static func getUserFilePath()->URL{
        let manager = FileManager.default
        let urlForDocument = manager.urls(for: .documentDirectory, in:.userDomainMask)
        let url = urlForDocument[0] as URL
        return url
    }
}
