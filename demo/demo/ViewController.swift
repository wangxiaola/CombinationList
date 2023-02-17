//
//  ViewController.swift
//  demo
//
//  Created by wxl on 2023/2/15.
//

import Cocoa

class ViewController: NSViewController {
    
    var scrollView: NSScrollView!
    var tableView: NSTableView!
    var leftClipView: NSClipView!
    var lefTableView: NSTableView!
    var dataArray: [String] = ["111","222","333","444"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.scrollView = NSScrollView.init()
        self.view.addSubview(self.scrollView)
        
        self.tableView = NSTableView.init()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = 50
        self.tableView.allowsColumnReordering = false
        self.tableView.gridStyleMask = .solidHorizontalGridLineMask
        self.tableView.headerView = nil
        self.tableView.rowSizeStyle = .custom
        self.tableView.intercellSpacing = NSSize(width: 0, height: 0)
        self.tableView.style = .plain
        self.tableView.enclosingScrollView?.borderType = .noBorder
        self.tableView.selectionHighlightStyle = .none
        self.scrollView.contentView.documentView = self.tableView
        
        let column1 = NSTableColumn.init(identifier: NSUserInterfaceItemIdentifier("column1"))
        column1.minWidth = 100
        column1.maxWidth = 100
        self.tableView.addTableColumn(column1)
        
        let column2 = NSTableColumn.init(identifier: NSUserInterfaceItemIdentifier("column2"))
        column2.minWidth = 100
        column2.maxWidth = 100
        self.tableView.addTableColumn(column2)
        
        
        self.leftClipView = NSClipView.init()
        
        self.lefTableView = NSTableView.init()
        self.lefTableView.delegate = self
        self.lefTableView.dataSource = self
        self.lefTableView.rowHeight = 50
        self.lefTableView.allowsColumnReordering = false
        self.lefTableView.gridStyleMask = .solidHorizontalGridLineMask
        self.lefTableView.registerForDraggedTypes([.string])
        self.lefTableView.draggingDestinationFeedbackStyle = .gap
        self.lefTableView.headerView = nil
        self.lefTableView.rowSizeStyle = .custom
        self.lefTableView.intercellSpacing = NSSize(width: 0, height: 0)
        self.lefTableView.style = .plain
        self.lefTableView.enclosingScrollView?.borderType = .noBorder
        self.lefTableView.selectionHighlightStyle = .none
        self.leftClipView.documentView = self.lefTableView
        self.scrollView.addSubview(self.leftClipView)
        
        let column3 = NSTableColumn.init(identifier: NSUserInterfaceItemIdentifier("column3"))
        column3.minWidth = 100
        column3.maxWidth = 100
        self.lefTableView.addTableColumn(column3)
        
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        self.scrollView.automaticallyAdjustsContentInsets = false
        self.scrollView.contentView.automaticallyAdjustsContentInsets = false
        self.leftClipView.automaticallyAdjustsContentInsets = false
        
        self.scrollView.contentView.contentInsets = NSEdgeInsets.init(top: 0, left: 140, bottom: 0, right: 0)
        self.tableView.reloadData()
        self.lefTableView.reloadData()
        // 滚动通知
        NotificationCenter.default.addObserver(self, selector: #selector(didLiveScroll(notification:)), name: NSScrollView.didLiveScrollNotification, object: nil)
        self.updateClipViewsLayout()
    }
    /// 更新视图偏移量
    func updateClipViewsLayout() {
        self.leftClipView.frame = CGRect(x: 0, y: -self.scrollView.documentVisibleRect.origin.y, width: 100, height: self.tableView.frame.height)
        
    }
    // 当视图szie发生变化时，需刷新子视图frame
    override func updateViewConstraints() {
        super.updateViewConstraints()
        self.updateClipViewsLayout()
    }
    
    // MARK: --- notification ---
    /// scrollView滚动通知
    @objc func didLiveScroll(notification: Notification) {
        self.updateClipViewsLayout()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}

extension ViewController: NSTableViewDataSource,NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.dataArray.count
    }
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return "\(tableColumn!.identifier.rawValue)=\(self.dataArray[row])"
    }
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        if tableView == self.tableView {return nil}
        let pasteboard = NSPasteboardItem()
        pasteboard.setString("\(row)", forType: .string)
        return pasteboard
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if tableView == self.tableView {return []}
        return .move
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        if tableView == self.tableView {return false}
        guard let items = info.draggingPasteboard.pasteboardItems,
              let pasteBoardItem = items.first,
              let pasteBoardItemName = pasteBoardItem.string(forType: .string)
        else {return false}
        let atIndex = Int(pasteBoardItemName) ?? 0
        let toIndex = (atIndex < row ? row - 1 : row)
        self.dataArray.swapAt(atIndex, toIndex)
        tableView.beginUpdates()
        tableView.moveRow(at: atIndex, to: toIndex)
        tableView.endUpdates()
        self.tableView.reloadData()
        return true
    }
}


