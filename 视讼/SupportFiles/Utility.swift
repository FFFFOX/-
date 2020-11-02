//
//  Utility.swift
//  视讼
//
//  Created by KlausZhang on 2020/7/27.
//  Copyright © 2020 KlausZhang. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

//MARK:- 添加圆角
 func setupCornerRadius(view: UIView,number: CGFloat) {
     view.clipsToBounds = true
     view.layer.cornerRadius = number
 }
 
 //MARK:- 添加阴影
func setupShadow(view: UIView, radius: CGFloat, opacity: CGFloat) {
     view.layer.shadowRadius = radius
    view.layer.shadowOpacity = Float(opacity)
     view.layer.shadowOffset = CGSize(width: 0, height: 0)
 }
extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}

extension UIImageView {
    @IBInspectable
    override var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    override var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    override var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    override var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    override var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    override var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    override var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}
fileprivate typealias buttonClick = ((UIButton)->())
extension UIButton {
    
    @objc private func clickAction() {
        self.actionBlock?(self)
    }
    
    private struct RuntimeKey {
        static let actionBlock = UnsafeRawPointer.init(bitPattern: "actionBlock".hashValue)
    }
    private var actionBlock: buttonClick? {
        set {
            objc_setAssociatedObject(self, UIButton.RuntimeKey.actionBlock!, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return  objc_getAssociatedObject(self, UIButton.RuntimeKey.actionBlock!) as? buttonClick
        }
    }

    
    func addAction(controlEvents: UIControl.Event = .touchUpInside ,handle:@escaping ((UIButton)->())) {
        self.actionBlock = handle
        self.addTarget(self, action: #selector(clickAction), for: controlEvents)
    }
    
}
//获取缓存大小
@discardableResult func getCacheSize() -> String {
    //cache文件夹
    let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
    //文件夹下所有文件
    let files = FileManager.default.subpaths(atPath: cachePath!)!
    //遍历计算大小
    var size = 0
    for file in files {
        //文件名拼接到路径中
        let path = cachePath! + "/\(file)"
        //取出文件属性
        do {
            let floder = try FileManager.default.attributesOfItem(atPath: path)
            for (key, fileSize) in floder {
                //累加
                if key == FileAttributeKey.size {
                    size += (fileSize as AnyObject).integerValue
                }
            }
        } catch {
            print("出错了！")
        }
        
    }
    
    let totalSize = Double(size) / 1024.0 / 1024.0
    print(String(format: "%.1fM", totalSize))
    return String(format: "%.1fM", totalSize)
}
func clearCache() {
    // 取出cache文件夹目录
    let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
    let fileArr = FileManager.default.subpaths(atPath: cachePath!)
    // 遍历删除
    for file in fileArr! {
        let path = (cachePath! as NSString).appending("/\(file)")
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch {
                print("出错了！")
            }
        }
    }
}
func pulseAnimation(toView: UIView) {
    let pulse = CASpringAnimation(keyPath: "transform.scale")
    pulse.damping = 7.5
    pulse.fromValue = 1.1
    pulse.toValue = 1.0
    pulse.duration = pulse.settlingDuration
    toView.layer.add(pulse, forKey: nil)
}
