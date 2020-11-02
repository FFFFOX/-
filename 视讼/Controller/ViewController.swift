//
//  ViewController.swift
//  视讼
//
//  Created by KlausZhang on 2020/7/25.
//  Copyright © 2020 KlausZhang. All rights reserved.
//

import UIKit
import FSCalendar
import RealmSwift
let realm = try! Realm()
class ViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate, UISearchBarDelegate, UITextFieldDelegate {
    
    enum Mode {
        case view
        case select
    }
    var mode:Mode = .view {
        didSet {
            switch mode {
            case .view:
                for (key, value) in dictionarySelectedIndxPath {
                    if value {
                        collectionView.deselectItem(at: key, animated: true)
                    }
                }
                dictionarySelectedIndxPath.removeAll()
                selectBtn.tintColor = .white
                trashBtn.isHidden = true
                collectionView.allowsMultipleSelection = false
            case .select:
                selectBtn.tintColor = #colorLiteral(red: 0.9609008431, green: 0.70410496, blue: 0.4610120654, alpha: 1)
                trashBtn.isHidden = false
                pulseAnimation(toView: trashBtn)
                collectionView.allowsMultipleSelection = true
            }
        }
    }
    var dictionarySelectedIndxPath: [IndexPath: Bool] = [:]
    var sideBar = UIView()
    var selectBtn = UIButton()
    var settingBtn = UIButton()
    var trashBtn = UIButton()
    var avatar = UIImageView()
    var mainTitle = UILabel()
    var searchBar = UISearchBar()
    var calendarBtn = UIButton()
    var listBtn = UIButton()
    var squareBtn = UIButton()
    var newDocumentBtn = UIButton()
    var collectionLayout: CollectionViewAnimationLayout = CollectionViewAnimationLayout()
    var collectionView: UICollectionView!
    var clickTimes = 0
    var calendar: FSCalendar!
    var blurView = UIView()
    var platform = UIView()
    var cancelBtn = UIButton()
    var doneBtn = UIButton()
    var preview = UIImageView()
    var textField = UITextField()
    var createTime:[String] = []
    var filteredTitles:[String] = []
    var alertController = UIAlertController()
    var tableView: UITableView!
    var listIsSelected: Bool = false
    var squareIsSelected: Bool = true
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
        }()
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override var shouldAutorotate: Bool {
        return false
    }
    
    var document = realm.objects(Document.self)
    override func viewDidLoad() {
        super.viewDidLoad()
        let filePathInSandbox = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        print(filePathInSandbox!)
        view.backgroundColor = .white
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        self.title = "卷宗"
        view.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.3142926395, green: 0.3881484568, blue: 0.6208400726, alpha: 1)
        let folderPath = realm.configuration.fileURL!.deletingLastPathComponent().path
        try! FileManager.default.setAttributes([FileAttributeKey(rawValue: FileAttributeKey.protectionKey.rawValue): FileProtectionType.none],ofItemAtPath: folderPath)
        for i in document.reversed() {
            let newDoc = i.title
            filteredTitles.append(newDoc)
        }
        blurView = UIView(frame: self.view.bounds)
        blurView.backgroundColor = #colorLiteral(red: 0.06274509804, green: 0.06274509804, blue: 0.06274509804, alpha: 0.74)
        hideKeyboardWhenTappedAround()
        setupDocumentsInCollection()
        setupDocumentsInTableView()
        setupSideBar()
        setupMainTitle()
        setupSearchBar()
        setupCalendarBtn()
        setupListBtn()
        setupSquareBtn()
        setupNewDocumentBtn()
        setupCalendar()
        constraints()
        
        alertController = UIAlertController(title: "温馨提示", message: "未填写卷宗标题", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "好的", style: .destructive) { (okAction) in
            print("okay")
        }
        alertController.addAction(okAction)
        print(realm.configuration.fileURL ?? "")
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        collectionView.reloadData()
        tableView.reloadData()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    //MARK:- 标题
    func setupMainTitle() {
        mainTitle = UILabel(frame: CGRect(x: 165, y: 65, width: 121, height: 72))
        mainTitle.text = "卷宗"
        mainTitle.textColor = #colorLiteral(red: 0.3363662362, green: 0.3862529993, blue: 0.6188088655, alpha: 1)
        mainTitle.font = UIFont.systemFont(ofSize: 60, weight: .bold)
        view.addSubview(mainTitle)
        
    }
    
    //MARK:- 添加左边菜单栏
    func setupSideBar() {
        //蓝边
        sideBar.backgroundColor = #colorLiteral(red: 0.3136612773, green: 0.3896692395, blue: 0.6188690662, alpha: 1)
        setupShadow(view: sideBar, radius: 5, opacity: 0.5)
        view.addSubview(sideBar)
        
        //头像
        avatar.image = UIImage(named: "avatar")
        setupCornerRadius(view: avatar, number: 5)
        setupShadow(view: avatar, radius: 5, opacity: 0.5)
        view.addSubview(avatar)
        
        //删除
        trashBtn.setImage(UIImage(systemName: "trash.fill")?.applyingSymbolConfiguration(.init(pointSize: 35)), for: .normal)
        trashBtn.tintColor = .white
        setupShadow(view: trashBtn, radius: 5, opacity: 0.5)
        trashBtn.isHidden = true
        trashBtn.addAction { (trashBtn) in
            pulseAnimation(toView: trashBtn)
            var deleteNeededIndexPaths: [IndexPath] = []
            for (key, value) in self.dictionarySelectedIndxPath {
                if value {
                    deleteNeededIndexPaths.append(key)
                }
            }
            for i in deleteNeededIndexPaths.sorted(by: { $0.item > $1.item }) {
                self.filteredTitles.remove(at: i.item)
                let item = self.document.reversed()[i.item]
                do {
                    try realm.write {
                        realm.delete(item)
                    }
                } catch {
                    print(error.localizedDescription)
                    return
                }
            }
            self.collectionView.deleteItems(at: deleteNeededIndexPaths)
            self.dictionarySelectedIndxPath.removeAll()
            self.tableView.reloadData()
        }
        view.addSubview(trashBtn)
        
        //多选
        selectBtn.setImage(UIImage(systemName: "checkmark.square")?.applyingSymbolConfiguration(.init(pointSize: 35)), for: .normal)
        selectBtn.tintColor = .white
        selectBtn.addAction {(selectBtn) in
            if self.tableView.isHidden == true {
                pulseAnimation(toView: self.selectBtn)
                self.mode = self.mode == .view ? .select : .view
            } else {
                selectBtn.tintColor = selectBtn.tintColor == UIColor(red: 0.9609008431, green: 0.70410496, blue: 0.4610120654, alpha: 1) ? UIColor.white : UIColor(red: 0.9609008431, green: 0.70410496, blue: 0.4610120654, alpha: 1)
                pulseAnimation(toView: self.selectBtn)
                self.tableView.setEditing(!self.tableView.isEditing, animated: true)
            }
        }
        setupShadow(view: selectBtn, radius: 5, opacity: 0.5)
        view.addSubview(selectBtn)
        //设置按钮
        settingBtn.setImage(UIImage(systemName: "slider.horizontal.3")?.applyingSymbolConfiguration(.init(pointSize: 35)), for: .normal)
        settingBtn.tintColor = .white
        setupShadow(view: settingBtn, radius: 5, opacity: 0.5)
        settingBtn.addAction { (selectBtn) in
            pulseAnimation(toView: self.settingBtn)
            print("setting")
            getCacheSize()
            clearCache()
            getCacheSize()
        }
        view.addSubview(settingBtn)
    }
    
    //MARK:- 添加搜索栏
    func setupSearchBar() {
        searchBar.searchBarStyle = .minimal
        searchBar.isTranslucent = true
        searchBar.barStyle = .default
        searchBar.delegate = self
        searchBar.placeholder = "type to search"
        view.addSubview(searchBar)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let oldFilteredTopic = self.filteredTitles
        
        if searchText.isEmpty {
            self.filteredTitles = self.document.map( {$0.title} ).reversed()
        } else {
            self.filteredTitles = self.document.map( {$0.title} ).filter({ (title) -> Bool in
                return title.contains(searchText)
            })
        }
        self.collectionView.performBatchUpdates({
            for (oldIndex, oldTitle) in oldFilteredTopic.enumerated() {
                if self.filteredTitles.contains(oldTitle) == false {
                    let indexPath = IndexPath(item: oldIndex, section: 0)
                    self.collectionView.deleteItems(at: [indexPath])
                    //                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                    
                }
            }
            for (index, title) in self.filteredTitles.enumerated() {
                if oldFilteredTopic.contains(title) == false {
                    let indexPath = IndexPath(item: index, section: 0)
                    self.collectionView.insertItems(at: [indexPath])
                    //                    self.tableView.insertRows(at: [indexPath], with: .fade)
                    
                }
            }
        }, completion: nil)
        
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    //MARK:- 添加日历按钮
    func setupCalendarBtn() {
        calendarBtn.setImage(UIImage(systemName: "calendar")?.applyingSymbolConfiguration(.init(pointSize: 30)), for: .normal)
        calendarBtn.backgroundColor = #colorLiteral(red: 0.3424350023, green: 0.420004487, blue: 0.6344532371, alpha: 1)
        calendarBtn.tintColor = .white
        setupCornerRadius(view: calendarBtn, number: 5)
        calendarBtn.addTarget(self, action: #selector(addCalendar(_:)), for: .touchUpInside)
        view.addSubview(calendarBtn)
        
    }
    @objc func addCalendar(_ sender: UIButton) {
        pulseAnimation(toView: calendarBtn)
        if sender.isTouchInside == true {
            clickTimes += 1
        }
        if clickTimes % 2 == 0 {
            UIView.animate(withDuration: 0.3, delay: 0, options: .transitionCrossDissolve, animations: {
                
                self.calendar.center.x += 384
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: .transitionCrossDissolve, animations: {
                self.calendar.center.x -= 384
            }, completion: nil)
        }
    }
    
    //MARK:- 设置日历
    func setupCalendar() {
        calendar = FSCalendar(frame: CGRect(x: UIScreen.main.bounds.width, y: 232, width: 300, height: 300))
        view.addSubview(calendar)
        calendar.select(Date())
        calendar.appearance.eventDefaultColor = #colorLiteral(red: 0.3424350023, green: 0.420004487, blue: 0.6344532371, alpha: 1)
        calendar.appearance.eventSelectionColor = #colorLiteral(red: 0.3424350023, green: 0.420004487, blue: 0.6344532371, alpha: 1)
        calendar.appearance.selectionColor = #colorLiteral(red: 0.3424350023, green: 0.420004487, blue: 0.6344532371, alpha: 1)
        calendar.appearance.todayColor = #colorLiteral(red: 0.3424350023, green: 0.420004487, blue: 0.6344532371, alpha: 1)
        calendar.appearance.weekdayTextColor = #colorLiteral(red: 0.3424350023, green: 0.420004487, blue: 0.6344532371, alpha: 1)
        calendar.appearance.headerTitleColor = #colorLiteral(red: 0.3424350023, green: 0.420004487, blue: 0.6344532371, alpha: 1)
        calendar.backgroundColor = .white
        setupCornerRadius(view: calendar, number: 10)
        calendar.layer.borderWidth = 2
        calendar.layer.borderColor = #colorLiteral(red: 0.3424350023, green: 0.420004487, blue: 0.6344532371, alpha: 1)
        calendar.delegate = self
        calendar.dataSource = self
        view.addGestureRecognizer(self.scopeGesture)
        calendar.scope = .month
    }
    
    //MARK:- 日历代理
    deinit {
        print("\(#function)")
    }
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("did select date \(self.dateFormatter.string(from: date))")
        let selectedDates = calendar.selectedDates.map({self.dateFormatter.string(from: $0)})
        print("selected dates is \(selectedDates)")
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("\(self.dateFormatter.string(from: calendar.currentPage))")
    }
    
    //MARK:- 列表式排列按钮
    func setupListBtn() {
        listBtn.setImage(UIImage(systemName: "list.dash")?.applyingSymbolConfiguration(.init(pointSize: 30)), for: .normal)
        listBtn.backgroundColor = #colorLiteral(red: 0.883051753, green: 0.9105229378, blue: 0.9417633414, alpha: 1)
        listBtn.tintColor = .white
        setupCornerRadius(view: listBtn, number: 5)
        listBtn.addAction { (listBtn) in
            pulseAnimation(toView: listBtn)
            if listBtn.backgroundColor == #colorLiteral(red: 0.883051753, green: 0.9105229378, blue: 0.9417633414, alpha: 1) {
                self.tableView.isHidden = false
                listBtn.backgroundColor = #colorLiteral(red: 0.3424350023, green: 0.420004487, blue: 0.6344532371, alpha: 1)
                self.squareBtn.backgroundColor = #colorLiteral(red: 0.883051753, green: 0.9105229378, blue: 0.9417633414, alpha: 1)
            }
        }
        view.addSubview(listBtn)
    }
    
    //MARK:- 方块式排里按钮
    func setupSquareBtn() {
        squareBtn.setImage(UIImage(systemName: "square.grid.2x2.fill")?.applyingSymbolConfiguration(.init(pointSize: 30)), for: .normal)
        squareBtn.tintColor = .white
        squareBtn.backgroundColor = #colorLiteral(red: 0.3424350023, green: 0.420004487, blue: 0.6344532371, alpha: 1)
        setupCornerRadius(view: squareBtn, number: 5)
        squareBtn.addAction { (squareBtn) in
            pulseAnimation(toView: squareBtn)
            if squareBtn.backgroundColor == #colorLiteral(red: 0.883051753, green: 0.9105229378, blue: 0.9417633414, alpha: 1) {
                self.tableView.isHidden = true
                squareBtn.backgroundColor = #colorLiteral(red: 0.3424350023, green: 0.420004487, blue: 0.6344532371, alpha: 1)
                self.listBtn.backgroundColor = #colorLiteral(red: 0.883051753, green: 0.9105229378, blue: 0.9417633414, alpha: 1)
            }
        }
        view.addSubview(squareBtn)
    }
    
    //MARK:- 创建卷宗平台
    func setupPlatform() {
        platform = UIView(frame: CGRect(x: blurView.center.x-289, y: blurView.center.y-190, width: 578, height: 380))
        platform.backgroundColor = .white
        platform.isUserInteractionEnabled = true
        setupCornerRadius(view: platform, number: 8)
        blurView.addSubview(platform)
        pulseAnimation(toView: platform)
        cancelBtn = UIButton(frame: CGRect(x: 20, y: 8, width: 70, height: 40))
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(#colorLiteral(red: 0.3424350023, green: 0.420004487, blue: 0.6344532371, alpha: 1), for: .normal)
        cancelBtn.addAction { (cancelBtn) in
            print("取消")
            self.doneBtn.removeFromSuperview()
            self.cancelBtn.removeFromSuperview()
            self.preview.removeFromSuperview()
            self.textField.removeFromSuperview()
            self.platform.removeFromSuperview()
            self.blurView.removeFromSuperview()
        }
        doneBtn = UIButton(frame: CGRect(x: 498, y: 8, width: 70, height: 40))
        doneBtn.setTitle("确定", for: .normal)
        doneBtn.setTitleColor(#colorLiteral(red: 0.3424350023, green: 0.420004487, blue: 0.6344532371, alpha: 1), for: .normal)
        doneBtn.addAction { (doneBtn) in
            if let text = self.textField.text {
                if text.count == 0 {
                    self.present(self.alertController, animated: true, completion: nil)
                } else {
                    print("确定")
                    let newDocumentId = (realm.objects(Document.self).max(ofProperty: "id") as Int? ?? 0 ) + 1
                    let newDocument = Document()
                    newDocument.id = newDocumentId
                    newDocument.title = self.textField.text!
                    newDocument.createTime = self.dateFormatter.string(from: Date())
                    do {
                        try! realm.write{
                            realm.add(newDocument)
                        }
                    }
                    self.filteredTitles.insert(newDocument.title, at: 0)
                    print(self.filteredTitles)
                    self.collectionView.insertItems(at: [IndexPath.init(row: 0, section: 0)])
                    self.tableView.reloadData()
                    self.platform.removeFromSuperview()
                    self.blurView.removeFromSuperview()
                    self.doneBtn.removeFromSuperview()
                    self.cancelBtn.removeFromSuperview()
                    self.preview.removeFromSuperview()
                    self.textField.removeFromSuperview()
                }
            }
        }
        preview = UIImageView(frame: CGRect(x: 213, y: 59, width: 150, height: 190))
        setupCornerRadius(view: preview, number: 8)
        preview.layer.borderColor = #colorLiteral(red: 0.3424350023, green: 0.420004487, blue: 0.6344532371, alpha: 1)
        preview.layer.borderWidth = 2
        
        textField = UITextField(frame: CGRect(x: 162, y: 276, width: 253, height: 34))
        textField.backgroundColor = #colorLiteral(red: 0.8979442716, green: 0.8980954289, blue: 0.8979231119, alpha: 1)
        textField.borderStyle = .roundedRect
        textField.placeholder = "请输入标题"
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.textAlignment = .center
        textField.delegate = self
        platform.addSubview(textField)
        platform.addSubview(preview)
        platform.addSubview(cancelBtn)
        platform.addSubview(doneBtn)
    }
    
    //MARK:- 新建卷宗
    func setupNewDocumentBtn() {
        newDocumentBtn.setImage(UIImage(systemName: "plus")?.applyingSymbolConfiguration(.init(pointSize: 25)), for: .normal)
        setupCornerRadius(view: newDocumentBtn, number: 5)
        newDocumentBtn.backgroundColor = #colorLiteral(red: 0.3424350023, green: 0.420004487, blue: 0.6344532371, alpha: 1)
        newDocumentBtn.tintColor = .white
        view.addSubview(newDocumentBtn)
        newDocumentBtn.addAction { (newDocumentBtn) in
            pulseAnimation(toView: newDocumentBtn)
            self.view.addSubview(self.blurView)
            self.setupPlatform()
        }
    }
    
    //MARK:- 显示卷宗byCollection
    func setupDocumentsInCollection() {
        collectionView = UICollectionView(frame: CGRect(x: 165, y: 240, width: view.frame.width-209, height: view.frame.height-260), collectionViewLayout: collectionLayout)
        collectionView.register(UINib(nibName: "DocumentsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "collectionCell")
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    //MARK:- 显示卷宗byTableView
    func setupDocumentsInTableView() {
        tableView = UITableView(frame: CGRect(x: 165, y: 240, width: view.frame.width-209, height: view.frame.height-260))
        tableView.register(UINib(nibName: "DocumentsTableViewCell", bundle: nil), forCellReuseIdentifier: "tableViewCell")
        tableView.backgroundColor = .white
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.addSubview(tableView)
    }
    
    
    //MARK:- 约束
    func constraints() {
        sideBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint.init(item: sideBar, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: sideBar, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: sideBar, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100),
            NSLayoutConstraint.init(item: sideBar, attribute: .height, relatedBy: .equal, toItem: nil , attribute: .notAnAttribute, multiplier: 1, constant: UIScreen.main.bounds.height)
        ])
        
        avatar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint.init(item: avatar, attribute: .top, relatedBy: .equal, toItem: sideBar, attribute: .top, multiplier: 1, constant: 74),
            NSLayoutConstraint.init(item: avatar, attribute: .leading, relatedBy: .equal, toItem: sideBar, attribute: .leading, multiplier: 1, constant: 20),
            NSLayoutConstraint.init(item: avatar, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60),
            NSLayoutConstraint.init(item: avatar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60),
        ])
        
        settingBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint.init(item: settingBtn, attribute: .leading, relatedBy: .equal, toItem: sideBar, attribute: .leading, multiplier: 1, constant: 27),
            NSLayoutConstraint.init(item: settingBtn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 47),
            NSLayoutConstraint.init(item: settingBtn, attribute: .bottom, relatedBy: .equal, toItem: sideBar , attribute: .bottom, multiplier: 1, constant: -81)
        ])
        
        selectBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint.init(item: selectBtn, attribute: .leading, relatedBy: .equal, toItem: sideBar, attribute: .leading, multiplier: 1, constant: 28),
            NSLayoutConstraint.init(item: selectBtn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44),
            NSLayoutConstraint.init(item: selectBtn, attribute: .trailing, relatedBy: .equal, toItem: sideBar, attribute: .trailing, multiplier: 1, constant: -28),
            NSLayoutConstraint.init(item: selectBtn, attribute: .bottom, relatedBy: .equal, toItem: settingBtn, attribute: .bottom, multiplier: 1, constant: -61),
        ])
        
        trashBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint.init(item: trashBtn, attribute: .leading, relatedBy: .equal, toItem: sideBar, attribute: .leading, multiplier: 1, constant: 27),
            NSLayoutConstraint.init(item: trashBtn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 47),
            NSLayoutConstraint.init(item: trashBtn, attribute: .bottom, relatedBy: .equal, toItem: selectBtn, attribute: .bottom, multiplier: 1, constant: -71),
        ])
        
        newDocumentBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint.init(item: newDocumentBtn, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 172),
            NSLayoutConstraint.init(item: newDocumentBtn, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -44),
            NSLayoutConstraint.init(item: newDocumentBtn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40),
            NSLayoutConstraint.init(item: newDocumentBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40),
        ])
        
        squareBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint.init(item: squareBtn, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 172),
            NSLayoutConstraint.init(item: squareBtn, attribute: .trailing, relatedBy: .equal, toItem: newDocumentBtn, attribute: .leading, multiplier: 1, constant: -25),
            NSLayoutConstraint.init(item: squareBtn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40),
            NSLayoutConstraint.init(item: squareBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40),
        ])
        
        listBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint.init(item: listBtn, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 172),
            NSLayoutConstraint.init(item: listBtn, attribute: .trailing, relatedBy: .equal, toItem: squareBtn, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: listBtn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40),
            NSLayoutConstraint.init(item: listBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40),
        ])
        
        calendarBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint.init(item: calendarBtn, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 172),
            NSLayoutConstraint.init(item: calendarBtn, attribute: .trailing, relatedBy: .equal, toItem: listBtn, attribute: .leading, multiplier: 1, constant: -25),
            NSLayoutConstraint.init(item: calendarBtn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40),
            NSLayoutConstraint.init(item: calendarBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40),
        ])
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint.init(item: searchBar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 170),
            NSLayoutConstraint.init(item: searchBar, attribute: .leading, relatedBy: .equal, toItem: sideBar, attribute: .trailing, multiplier: 1, constant: 65),
            NSLayoutConstraint.init(item: searchBar, attribute: .trailing, relatedBy: .equal, toItem: calendarBtn, attribute: .leading, multiplier: 1, constant: -25),
            NSLayoutConstraint.init(item: searchBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44)
        ])
        
    }
    
}

extension UIViewController{
    //隐藏键盘
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    // MARK:- UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 250)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 20, left: 20, bottom: 0, right: 20)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    // MARK:- UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredTitles.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! DocumentsCollectionViewCell
        cell.thumbnail.borderColor = #colorLiteral(red: 0.3424350023, green: 0.420004487, blue: 0.6344532371, alpha: 1)
        cell.thumbnail.borderWidth = 2
        var reversedDoc:[Document] = []
        for i in document.reversed() {
            reversedDoc.append(i)
        }
        let item = reversedDoc[indexPath.item]
        cell.titleOfDocument.text = item.title
        cell.createTime.text = item.createTime
        let data = Data()
        cell.thumbnail.image = UIImage(data: item.thumbnail ?? data)
        setupShadow(view: cell.thumbnail, radius: 5, opacity: 0.5)
        setupCornerRadius(view: cell, number: 8)
        setupCornerRadius(view: cell.thumbnail, number: 8)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch mode {
        case .view:
            collectionView.deselectItem(at: indexPath, animated: true)
            let documents = (document.reversed()[indexPath.row], indexPath.row)
            let vc = OperatingPlatformViewController()
            vc.document = documents.0
            vc.documentIndex = documents.1
            self.navigationController?.pushViewController(vc, animated: true)
        case .select:
            dictionarySelectedIndxPath[indexPath] = true
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if mode == .select {
            dictionarySelectedIndxPath[indexPath] = false
        }
    }
}

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    // MARK:- UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTitles.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! DocumentsTableViewCell
        cell.thumbnail.borderColor = #colorLiteral(red: 0.3424350023, green: 0.420004487, blue: 0.6344532371, alpha: 1)
        cell.thumbnail.borderWidth = 2
        var reversedDoc:[Document] = []
        for i in document.reversed() {
            reversedDoc.append(i)
        }
        let item = reversedDoc[indexPath.row]
        cell.title.text = item.title
        cell.createTime.text = item.createTime
        let data = Data()
        cell.thumbnail.image = UIImage(data: item.thumbnail ?? data)
        setupShadow(view: cell.thumbnail, radius: 5, opacity: 0.5)
        setupCornerRadius(view: cell, number: 8)
        setupCornerRadius(view: cell.thumbnail, number: 8)
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.filteredTitles.remove(at: indexPath.row)
            do {
                try realm.write {
                    realm.delete(self.document.reversed()[indexPath.row])
                }
            } catch let error as NSError {
                print(error.localizedDescription)
                return
            }
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            self.collectionView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let documents = (document.reversed()[indexPath.row], indexPath.row)
        let vc = OperatingPlatformViewController()
        vc.document = documents.0
        vc.documentIndex = documents.1
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
