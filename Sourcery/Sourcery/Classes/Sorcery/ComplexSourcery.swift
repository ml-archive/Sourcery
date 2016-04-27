//
//  ComplexSourcery.swift
//  Sourcery
//
//  Created by Dominik Hádl on 27/04/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import UIKit

public class ComplexSourcery: NSObject, TableController {

    public private(set) weak var tableView: UITableView?

    /// Setting a custom height will override the height of all cells to the value specified.
    /// If the value is nil, the `staticHeight` property of each cell will be used instead.
    var autoDeselect = true

    /// TODO: Documentation
    var sections: [SectionType] {
        didSet {
            tableView?.reloadData()
        }
    }

    /// TODO: Documentation
    var headerHeight: CGFloat = 32.0

    // MARK: - Init -

    private override init() {
        fatalError("Never instantiate this class directly. Use the init(tableView:sections:) initializer.")
    }

    public required init(tableView: UITableView, sections: [SectionType]) {
        self.tableView = tableView
        self.sections = sections
        super.init()

        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        self.tableView?.reloadData()
    }

    // MARK: - UITableView Data Source & Delegate -

    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].dataCount
    }

    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return sections[indexPath.section].heightForCellAtIndex(indexPath.row)
    }

    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections[section].title != nil ? headerHeight : 0
    }

    public func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return sections[section].title != nil ? headerHeight : 0
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let constructor = sections[indexPath.section].customConstructors[indexPath.row] {
            return constructor(tableView: tableView, index: indexPath.row)
        }

        let type = sections[indexPath.section].cellType
        let cell = tableView.dequeueCellTypeDefault(type)
        sections[indexPath.section].configureCell(cell, index: indexPath.row)
        return cell
    }

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if autoDeselect { tableView.deselectRowAtIndexPath(indexPath, animated: true) }
        sections[indexPath.section].handleSelection(indexPath.row)
    }
}