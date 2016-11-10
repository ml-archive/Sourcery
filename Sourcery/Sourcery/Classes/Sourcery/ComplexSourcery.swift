//
//  ComplexSourcery.swift
//  Sourcery
//
//  Created by Dominik Hádl on 27/04/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import UIKit

open class ComplexSourcery: NSObject, TableController {

    public typealias HeaderConfigurator = ((_ section: Int, _ header: UITableViewHeaderFooterView?, _ title: String?) -> Void)

    open fileprivate(set) weak var tableView: UITableView?

    /// Setting a custom height will override the height of all cells to the value specified.
    /// If the value is nil, the `staticHeight` property of each cell will be used instead.
    var autoDeselect = true

    /// TODO: Documentation
    open fileprivate(set) var sections: [SectionType] {
        didSet {
            tableView?.reloadData()
        }
    }

    /// TODO: Documentation
    var headerHeight: CGFloat = 32.0

    /// TODO: Documentation
    fileprivate var headerConfigurator: HeaderConfigurator?

    /// If set, then some UITableView delegate methods will be sent to it.
    open var delegateProxy: TableViewDelegateProxy?

    // MARK: - Init -

    fileprivate override init() {
        fatalError("Never instantiate this class directly. Use the init(tableView:sections:) initializer.")
    }

    public required init(tableView: UITableView, sections: [SectionType], headerConfigurator: HeaderConfigurator? = nil) {
        self.tableView = tableView
        self.sections = sections
        self.headerConfigurator = headerConfigurator
        super.init()

        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        self.tableView?.reloadData()
    }

    // MARK: - Update Data -

    open func update(sections newSections: [SectionType]) {
        sections = newSections
        tableView?.reloadData()
    }

    // MARK: - UITableView Data Source & Delegate -

    open func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].dataCount
    }

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sections[indexPath.section].heightForCell(atIndex: indexPath.row)
    }

    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // If we have a header, return its height
        return sections[section].headerType?.staticHeight ?? (sections[section].title != nil ? headerHeight : 0)
    }

    open func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        // If we have a header, return its height
        return sections[section].headerType?.staticHeight ?? (sections[section].title != nil ? headerHeight : 0)
    }

    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // If a header is specified - dequeue, configure and return it
        if let type = sections[section].headerType {
            let header = tableView.dequeueHeaderFooterView(type)
            headerConfigurator?(section, header, sections[section].title)
            return header
        }

        return nil
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let constructor = sections[indexPath.section].customConstructors[indexPath.row] {
            return constructor(tableView, indexPath.row)
        }

        let type = sections[indexPath.section].cellType
        let cell = tableView.dequeueDefault(cellType: type)
        sections[indexPath.section].configure(cell: cell, index: indexPath.row)
        return cell
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if autoDeselect { tableView.deselectRow(at: indexPath, animated: true) }
        sections[indexPath.section].handle(selection: indexPath.row)
    }

    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegateProxy?.scrollViewDidScroll(scrollView)
    }
}
