//
//  SimpleSourcery.swift
//  Sourcery
//
//  Created by Dominik Hádl on 27/04/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import UIKit

open class SimpleSourcery<DataType, CellType: TableViewPresentable>: NSObject, TableController {

    public typealias SelectionHandler = ((_ index: Int, _ object: DataType) -> Void)
    public typealias CellConfigurator = ((_ cell: CellType, _ index: Int, _ object: DataType) -> Void)

    open fileprivate(set) weak var tableView: UITableView?
    open fileprivate(set) var data = [DataType]()
    fileprivate var selectionHandler: SelectionHandler?
    fileprivate var configurator: CellConfigurator?

    /// If enabled, the cell will be automatically deselected (animated) 
    /// after `tableView(_:didSelectRowAtIndexPath:)` is called.
    open var autoDeselect = true

    /// Setting a custom height will override the height of all cells to the value specified.
    /// If the value is nil, the `staticHeight` property of each cell will be used instead.
    open var customHeight: CGFloat?

    /// If set, then some UITableView delegate methods will be sent to it.
    open var delegateProxy: TableViewDelegateProxy?

    // MARK: - Init -

    fileprivate override init() {
        fatalError("Never instantiate this class directly. Use the init(tableView:data:cellConfigurator:selectionHandler:) initializer.")
    }

    public required init(tableView: UITableView, data: [DataType], configurator: CellConfigurator?, selectionHandler: SelectionHandler? = nil) {
        self.tableView = tableView
        self.data      = data
        self.selectionHandler = selectionHandler
        self.configurator     = configurator
        super.init()

        self.tableView?.dataSource = self
        self.tableView?.delegate   = self
        self.tableView?.reloadData()
    }

    // MARK: - Update Data -

    open func update(data newData: [DataType]) {
        data = newData
        tableView?.reloadData()
    }

    // MARK: - UITableView Data Source & Delegate -

    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Custom height if defined, otherwise the cell height
        return customHeight ?? CellType.staticHeight
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue or register the cell
        let cell: CellType = tableView.dequeue(cellType: CellType.self)

        // Configure it using the configurator
        configurator?(cell, indexPath.row, data[indexPath.row])

        // Return as UITableViewCell
        return cell as! UITableViewCell
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect row, if auto deselect enabled
        if autoDeselect { tableView.deselectRow(at: indexPath, animated: true) }

        // Call the selection handler
        selectionHandler?(indexPath.row, data[indexPath.row])
    }

    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegateProxy?.scrollViewDidScroll(scrollView)
    }
}
