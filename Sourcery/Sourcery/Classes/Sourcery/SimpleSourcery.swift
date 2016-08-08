//
//  SimpleSourcery.swift
//  Sourcery
//
//  Created by Dominik Hádl on 27/04/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import UIKit

public class SimpleSourcery<DataType, CellType: TableViewPresentable>: NSObject, TableController {

    public typealias SelectionHandler = ((index: Int, object: DataType) -> Void)
    public typealias CellConfigurator = ((cell: CellType, index: Int, object: DataType) -> Void)

    public private(set) weak var tableView: UITableView?
    public private(set) var data = [DataType]()
    private var selectionHandler: SelectionHandler?
    private var configurator: CellConfigurator?

    /// If enabled, the cell will be automatically deselected (animated) 
    /// after `tableView(_:didSelectRowAtIndexPath:)` is called.
    public var autoDeselect = true

    /// Setting a custom height will override the height of all cells to the value specified.
    /// If the value is nil, the `staticHeight` property of each cell will be used instead.
    public var customHeight: CGFloat?

    // MARK: - Init -

    private override init() {
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

    public func updateData(newData newData: [DataType]) {
        data = newData
        tableView?.reloadData()
    }

    // MARK: - UITableView Data Source & Delegate -

    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // Custom height if defined, otherwise the cell height
        return customHeight ?? CellType.staticHeight
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Dequeue or register the cell
        let cell: CellType = tableView.dequeueCellType(CellType)

        // Configure it using the configurator
        configurator?(cell: cell, index: indexPath.row, object: data[indexPath.row])

        // Return as UITableViewCell
        return cell as! UITableViewCell
    }

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Deselect row, if auto deselect enabled
        if autoDeselect { tableView.deselectRowAtIndexPath(indexPath, animated: true) }

        // Call the selection handler
        selectionHandler?(index: indexPath.row, object: data[indexPath.row])
    }
}