//
//  OperatingPlatformViewController.swift
//  视讼
//
//  Created by KlausZhang on 2020/7/26.
//  Copyright © 2020 KlausZhang. All rights reserved.
//

import UIKit
import Floaty
import OHMySQL
import Starscream
import RealmSwift

class OperatingPlatformViewController: UIViewController,  UITextFieldDelegate,UITextViewDelegate,WebSocketDelegate {
    
    var clickTimes = -1
    var timeAxis = UIImageView()
    //MARK:- WebSocket初始化
    var socket: WebSocket!
    var isConnected = false
    let server = WebSocketServer()

    var document: Document!
    var part = realm.objects(Parts.self)
    var documentIndex: Int!
    
    private var newCellSizeForTimeAxis: CGSize = .init(width: UIScreen.main.bounds.width / 2 - 40, height: 190)
    private var newCellSizeForRelationship: CGSize = .init(width: UIScreen.main.bounds.width / 2 - 40, height: 190)
    var navigation: UIView!
    var topic = UILabel()
    var addBtn = Floaty()
    var displayArea = UIScrollView()
    var backBtn = UIButton()
    var saveBtn = UIButton()
    var collectionView: UICollectionView!
    var collectionLayout = CollectionViewAnimationLayout()
    var filePath  = ""
    var clientDetailsImage = UIImageView()
    var clientDetailsLabel = UILabel()
    var divider = UILabel()
    var clientNameImage = UIImageView()
    var clientPeopleImage = UIImageView()
    var clientAddressImage = UIImageView()
    var clientNameLabel = UILabel()
    var clientPeopleLabel = UILabel()
    var clientAddressLabel = UILabel()
    var clientNameArea = UILabel()
    var clientPeopleArea = UILabel()
    var clientAddressArea = UILabel()
    var clientDetailsCardView = UIView()
    override var shouldAutorotate: Bool {
        return false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = document.title
        if self.document.clickTimesForCD >= 1 {
            clientDetailsCard()
        }
        hideKeyboardWhenTappedAround()
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        //MARK:- Websocket连接
        var request = URLRequest(url: URL(string: "http://121.40.64.188:8080")!) //https://127.0.0.1:9999
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
        view.backgroundColor = #colorLiteral(red: 0.9018767476, green: 0.9020003676, blue: 0.9018548131, alpha: 1)
        let navigationTitleAttribute: NSDictionary = NSDictionary(object: UIColor.white, forKey: NSAttributedString.Key.foregroundColor as NSCopying)
        self.navigationController?.navigationBar.titleTextAttributes = navigationTitleAttribute as? [NSAttributedString.Key : Any]
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.tintColor = .white
        let saveBtn = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .done, target: self, action: #selector(save(_:)))
        navigationItem.rightBarButtonItem = saveBtn
        setupDisplayArea()
        setupAddBtn()
        setupWorkplaceArea()
    }
    @objc func save(_ sender: UIButton) {
        print("保存")
        saveAsPDF()
        saveToImage()
        shareFile(filePath)
    }
    //MARK:- 保存为PDf
    func saveAsPDF() {
        // 初始化可变data类型变量接收scrollview转换的数据
        let pdfData:NSMutableData = NSMutableData.init()
        // 展开画布并开始转换
        UIGraphicsBeginPDFContextToData(pdfData, CGRect(x:0,y:0, width:displayArea.contentSize.width, height:displayArea.contentSize.height), nil)
        // 展开PDF页面
        UIGraphicsBeginPDFPageWithInfo(CGRect(x:0, y:0,width: displayArea.contentSize.width,height:displayArea.contentSize.height), nil)
        // 获取当前上下文
        let pdfContext = UIGraphicsGetCurrentContext()
        let originSize = displayArea.frame
        var newSize = originSize
        newSize.size = displayArea.contentSize
        displayArea.frame = newSize
        // 将scrollview数据渲染到上下文
        displayArea.layer.render(in: pdfContext!)
        displayArea.frame = originSize
        // 停止转换/关闭画布
        UIGraphicsEndPDFContext()
        var filePathInSandbox = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        filePathInSandbox = filePathInSandbox!+"/\(document.title).pdf"
        // 写入本地PDF文件
        pdfData.write(toFile: filePathInSandbox!, atomically: true)
        filePath = filePathInSandbox!
        print(filePathInSandbox!)
        print(pdfData)
        getCacheSize()
    }
    
    //MARK:- 保存为图片
    func saveToImage() {
        var image: UIImage? = nil
        UIGraphicsBeginImageContext(displayArea.contentSize)
        do {
            let savedContentOffset = displayArea.contentOffset
            let savedFrame = displayArea.frame
            displayArea.contentOffset = CGPoint.zero
            displayArea.frame = CGRect(x: 0, y: 0, width: displayArea.contentSize.width, height: displayArea.contentSize.height)
            if let context = UIGraphicsGetCurrentContext() {
                displayArea.layer.render(in: context)
            }
            image = UIGraphicsGetImageFromCurrentImageContext()
            displayArea.contentOffset = savedContentOffset
            displayArea.frame = savedFrame
        }
        UIGraphicsEndImageContext()
        let imageData = image!.pngData()
        do {
            try! realm.write {
                self.document.thumbnail = imageData
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    //MARK:- 左侧
    func setupWorkplaceArea() {
        collectionView = UICollectionView(frame: CGRect(x: 20, y: 71, width: view.frame.width / 2 - 40, height: view.frame.height-91),collectionViewLayout: collectionLayout)
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    //MARK:- 添加按钮
    func setupAddBtn() {
        addBtn = Floaty()
        Floaty.global.rtlMode = false
        addBtn.buttonColor = #colorLiteral(red: 0.3424350023, green: 0.420004487, blue: 0.6344532371, alpha: 1)
        addBtn.plusColor = .white
        addBtn.overlayColor = .clear
        addBtn.itemTitleColor = #colorLiteral(red: 0.3424350023, green: 0.420004487, blue: 0.6344532371, alpha: 1)
        addBtn.isDraggable = true
        addBtn.addItem("当事人信息",icon: UIImage(named: "当事人"),handler: {
            iterm in
            print("点击了当事人信息")
            do {
                try! realm.write {
                    self.document.clickTimes += 1
                    self.document.clickTimesForCD += 1
                }
            }
            if self.document.clickTimesForCD == 1 {
                self.addPart(str: "clientDetails")
                self.clientDetailsCard()
                self.collectionView.register(UINib(nibName: "ClientCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "clientDetails")
                self.collectionView.insertItems(at: [IndexPath.init(row: Int(self.document.clickTimes), section: 0)])
            }   
            if self.document.clickTimesForCD > 1 {
                print("you have added one")
            }
            self.saveToImage()
        })
        addBtn.addItem("关系图", icon: UIImage(named: "关系图"),handler: {
            iterm in
            print("点击了关系图")
            do {
                try! realm.write {
                    self.document.clickTimes += 1
                    self.document.clickTimesForRS += 1
                }
            }
            if self.document.clickTimesForRS == 1 {
                self.addPart(str: "relationship")
                self.collectionView.register(UINib(nibName: "RelationshipCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "relationship")
                self.collectionView.insertItems(at: [IndexPath.init(row: Int(self.document.clickTimes), section: 0)])
            }
            if self.document.clickTimesForRS > 1 {
                print("you have added one")
            }
            self.saveToImage()
        })
        addBtn.addItem("时间轴", icon: UIImage(named: "时间轴"),handler: {
            iterm in
            print("点击了时间轴")
            do {
                try! realm.write {
                    self.document.clickTimes += 1
                    self.document.clickTimesForTA += 1
                }
            }
            if self.document.clickTimesForTA == 1 {
                self.addPart(str: "timeAxis")
                self.collectionView.register(UINib(nibName: "TimeAxisCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "timeAxisCell")
                self.collectionView.insertItems(at: [IndexPath.init(row: Int(self.document.clickTimes), section: 0)])
            }
            if self.document.clickTimesForTA > 1 {
                print("you have added one")
            }
            self.saveToImage()
        })
        addBtn.addItem("折线图", icon: UIImage(named: "折线图"),handler: {
            iterm in print("点击了折线图")
            self.saveToImage()
        })
        addBtn.addItem("饼状图", icon: UIImage(named: "饼状图"),handler: {
            iterm in print("点击了饼状图")
            self.saveToImage()
        })
        addBtn.addItem("表格", icon: UIImage(named: "表格"),handler: {
            iterm in print("点击了表格")
            self.saveToImage()
        })
        self.view.addSubview(addBtn)
    }
    func addPart (str: String){
        let part = Parts()
        part.item = str
        do {
            try! realm.write {
                document.parts.append(part)
            }
        }
    }
    //MARK:- 添加右侧展示区
    func setupDisplayArea() {
        displayArea.contentSize = CGSize(width: view.frame.width / 2 - 40, height: 779)
        displayArea.backgroundColor = .white
        setupCornerRadius(view: displayArea, number: 5)
        setupShadow(view: displayArea, radius: 5, opacity: 0.5)
        displayArea.indicatorStyle = .default
        view.addSubview(displayArea)
        displayArea.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint.init(item: displayArea, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 71),
            NSLayoutConstraint.init(item: displayArea, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -20),
            NSLayoutConstraint.init(item: displayArea, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: view.frame.width / 2 - 40),
            NSLayoutConstraint.init(item: displayArea, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -20),
        ])
    }
    //MARK:- 显示当事人信息
    func clientDetailsCard() {
        clientDetailsCardView = UIView(frame: CGRect(x: 0, y: 0, width: 560, height: 255))
        setupCornerRadius(view: clientDetailsCardView, number: 5)
        displayArea.addSubview(clientDetailsCardView)
        clientNameImage = UIImageView(frame: CGRect(x: 30, y: 15, width: 50, height: 50))
        clientNameImage.image = UIImage(named: "client")
        clientDetailsCardView.addSubview(clientNameImage)
        clientDetailsLabel = UILabel(frame: CGRect(x: 110, y: 30, width: 109, height: 21))
        clientDetailsLabel.text = "当事人信息"
        clientDetailsLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        clientDetailsCardView.addSubview(clientDetailsLabel)
        divider = UILabel(frame: CGRect(x: 39, y: 68, width: 521, height: 21))
        divider.text = "——————"
        divider.textColor = #colorLiteral(red: 0.3424350023, green: 0.420004487, blue: 0.6344532371, alpha: 1)
        divider.font = UIFont.systemFont(ofSize: 17, weight: .black)
        clientDetailsCardView.addSubview(divider)
        clientNameImage = UIImageView(frame: CGRect(x: 50, y: 102, width: 30, height: 30))
        clientNameImage.image = UIImage(named: "identity")
        clientDetailsCardView.addSubview(clientNameImage)
        clientPeopleImage = UIImageView(frame: CGRect(x: 50, y: 145, width: 30, height: 30))
        clientPeopleImage.image = UIImage(named: "people")
        clientDetailsCardView.addSubview(clientPeopleImage)
        clientAddressImage = UIImageView(frame: CGRect(x: 50, y: 188, width: 30, height: 30))
        clientAddressImage.image = UIImage(named: "location")
        clientDetailsCardView.addSubview(clientAddressImage)
        clientNameLabel = UILabel(frame: CGRect(x: 110, y: 107, width: 35, height: 21))
        clientNameLabel.text = "姓名"
        clientNameLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        clientDetailsCardView.addSubview(clientNameLabel)
        clientPeopleLabel = UILabel(frame: CGRect(x: 110, y: 149, width: 35, height: 21))
        clientPeopleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        clientPeopleLabel.text = "民族"
        clientDetailsCardView.addSubview(clientPeopleLabel)
        clientAddressLabel = UILabel(frame: CGRect(x: 110, y: 193, width: 35, height: 21))
        clientAddressLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        clientAddressLabel.text = "地址"
        clientDetailsCardView.addSubview(clientAddressLabel)
        clientNameArea = UILabel(frame: CGRect(x: 189, y: 100, width: 275, height: 34))
        clientNameArea.text = self.document.clientName
        clientDetailsCardView.addSubview(clientNameArea)
        clientPeopleArea = UILabel(frame: CGRect(x: 189, y: 143, width: 275, height: 34))
        clientPeopleArea.text = self.document.clientNation
        clientDetailsCardView.addSubview(clientPeopleArea)
        clientAddressArea = UILabel(frame: CGRect(x: 189, y: 186, width: 275, height: 34))
        clientAddressArea.text = self.document.clientAddress
        clientDetailsCardView.addSubview(clientAddressArea)
    }
    //MARK:- 添加时间轴图片
    func setupTimeAxis() {
        timeAxis = UIImageView(frame: CGRect(x: 30, y: 265, width: 530, height: 255))
        timeAxis.contentMode = .scaleAspectFit
        self.displayArea.addSubview(timeAxis)
    }
    //MARK:- 接收状态
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
            var alertViewController = UIAlertController()
            alertViewController = UIAlertController(title: "温馨提示", message: "未能生成时间轴，请核对输入内容", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "好的", style: .destructive) { (okAction) in
                print("okay")
            }
            alertViewController.addAction(okAction)
            if string == "error" {
                self.present(alertViewController, animated: true, completion: nil)
            }
        case .binary(let data):
            print("Received data: \(data.count)")
            print("\(data)")
            print(type(of: data))
            do {
                try! realm.write {
                    document.timeAxisPic = data
                }
            }
            print(document.timeAxisPic!)
            self.timeAxis.image = UIImage(data: document.timeAxisPic ?? data)
        case .ping:
            break
        case .pong:
            break
        case .viabilityChanged:
            break
        case .reconnectSuggested:
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            handleError(error)
        }
    }
    
    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            print("websocket encountered an error: \(e.message)")
        } else if let e = error {
            print("websocket encountered an error: \(e.localizedDescription)")
        } else {
            print("websocket encountered an error")
        }
    }
    
    
    //MARK:- 导出文件
    func shareFile(_ filePath: String) {
        
        let controller = UIActivityViewController(
            activityItems: [NSURL(fileURLWithPath: filePath)],
            applicationActivities: nil)
        
        controller.excludedActivityTypes = [
            .postToTwitter,
            .postToFacebook,
            .postToTencentWeibo,
            .postToWeibo,
            .postToFlickr,
            .postToVimeo,
            .message,
            .addToReadingList,
            .print,
            .copyToPasteboard,
            .assignToContact,
            .saveToCameraRoll
        ]
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            controller.popoverPresentationController?.sourceView = view
            controller.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.size.width * 0.5, y: UIScreen.main.bounds.size.height * 0.5, width: 100, height: 100)
        }
        if (self.presentedViewController == nil) {
            self.present(controller, animated: true, completion: nil)
        }
    }
}

extension OperatingPlatformViewController: TimeAxisCollectionViewCellDelegate {
    func updateLayout(_ cell: TimeAxisCollectionViewCell, with newSize: CGSize) {
        newCellSizeForTimeAxis.height = newSize.height + 145
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
}
extension OperatingPlatformViewController: RelationshipCollectionViewCellDelegate {
    func updateLayout(_ cell: RelationshipCollectionViewCell, with newSize: CGSize) {
        newCellSizeForRelationship.height = newSize.height + 145
        collectionView.collectionViewLayout.invalidateLayout()
    }
}
extension OperatingPlatformViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return document.parts.count
    }
    //MARK:- cellForItemAt的代理以及数据发送数据库
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var reversedPart:[Parts] = []
        for i in document.parts {
            reversedPart.append(i)
        }
        let item = reversedPart[indexPath.item]
        switch item.item {
        case "clientDetails":
            self.collectionView.register(UINib(nibName: "ClientCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "clientDetails")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "clientDetails", for: indexPath) as! ClientCollectionViewCell
            
            setupCornerRadius(view: cell, number: 5)
            setupShadow(view: cell, radius: 5, opacity: 0.5)
            cell.nameTextField.delegate = self
            cell.peopleTextField.delegate = self
            cell.addressTextField.delegate = self
            cell.nameTextField.text = self.document.clientName != "" ? self.document.clientName : ""
            cell.peopleTextField.text = self.document.clientNation != "" ? self.document.clientNation : ""
            cell.addressTextField.text = self.document.clientAddress != "" ? self.document.clientAddress : ""
            cell.confirmBtn.addAction { (confirmBtn) in
                pulseAnimation(toView: confirmBtn)
                do {
                    try! realm.write {
                        self.document.clientName = cell.nameTextField.text!
                        self.document.clientNation = cell.peopleTextField.text!
                        self.document.clientAddress = cell.addressTextField.text!
                    }
                }
                self.clientDetailsCardView.removeFromSuperview()
                self.clientDetailsCard()
                self.saveToImage()
            }
            return cell
        case "timeAxis":
            self.collectionView.register(UINib(nibName: "TimeAxisCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "timeAxisCell")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "timeAxisCell", for: indexPath) as! TimeAxisCollectionViewCell
            setupCornerRadius(view: cell, number: 5)
            setupShadow(view: cell, radius: 5, opacity: 0.5)
            cell.delegate = self
            cell.textView.delegate = self
            cell.textView.text = self.document.timeAxisInfo != "" ? self.document.timeAxisInfo : ""
            cell.confirmBtn.addAction { (confirmBtn) in
                pulseAnimation(toView: confirmBtn)
                do {
                    try! realm.write {
                        self.document.timeAxisInfo = cell.textView.text
                    }
                }
                self.saveToImage()
                
                //MARK:- 🌟
                let cat:String = "1"
                let date = Date()
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "yyyy-MM-dd HH:mm"
                let time:String = dateFormat.string(from: date)
                let text:String = cat+"#"+time
                //MARK:- 数据库
                let word:String = cell.textView.text
                //MARK:- 初始化
                let user = OHMySQLUser(userName: "CCCC", password: "12345678", serverName: "121.40.64.188", dbName: "CCCC", port: 3306, socket: nil)
                let coordinator = OHMySQLStoreCoordinator(user: user!)
                coordinator.encoding = .UTF8MB4
                coordinator.connect()
                //MARK:- 协调器
                let context = OHMySQLQueryContext()
                context.storeCoordinator = coordinator
                //MARK:- 输入
                let query = OHMySQLQueryRequestFactory.insert("content", set: ["text": word, "cat": cat, "time": time])
                try? context.execute(query)
                //MARK:- 关闭连接
                coordinator.disconnect()
                self.socket.write(string: text)
                if cell.textView.text != ""{
                    //MARK:- 图片
                    self.setupTimeAxis()
                }
            }
            return cell
        case "relationship":
            self.collectionView.register(UINib(nibName: "RelationshipCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "relationship")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "relationship", for: indexPath) as! RelationshipCollectionViewCell
            cell.textView.delegate = self
            cell.textView.text = self.document.relationshipInfo != "" ? self.document.relationshipInfo : ""
            cell.confirmBtn.addAction { (confirmBtn) in
                pulseAnimation(toView: confirmBtn)
                do {
                    try! realm.write {
                        self.document.relationshipInfo = cell.textView.text
                    }
                }
                self.saveToImage()
            }
            setupCornerRadius(view: cell, number: 5)
            setupShadow(view: cell, radius: 5, opacity: 0.5)
            cell.delegate = self
            return cell
        default:
            let cell = UICollectionViewCell()
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var reversedPart:[Parts] = []
        for i in document.parts {
            reversedPart.append(i)
        }
        let item = reversedPart[indexPath.item]
        switch item.item {
        case "clientDetails":
            return CGSize(width: UIScreen.main.bounds.width / 2 - 40, height: 230)
        case "timeAxis":
            return newCellSizeForTimeAxis
        case "relationship":
            return newCellSizeForRelationship
        default:
            return CGSize(width: UIScreen.main.bounds.width / 2 - 40, height: 230)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}
