//
//  Section.swift
//  Sourcery
//
//  Created by Dominik Hádl on 24/04/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import UIKit

public struct Section<DataType, CellType: TableViewPresentable>: SectionType {

    public typealias SelectionHandler = ((_ index: Int, _ object: DataType) -> Void)
    public typealias CellConfigurator = ((_ cell: CellType, _ index: Int, _ object: DataType) -> Void)
    public typealias HeightConfigurator = ((_ index: Int, _ object: DataType) -> CGFloat)

    public fileprivate(set) var data = [DataType]()
    fileprivate var selectionHandler: SelectionHandler?
    fileprivate var configurator: CellConfigurator?
    fileprivate var heightConfigurator: HeightConfigurator?

    public fileprivate(set) var title: String?

    public var customConstructors: [Int: CellConstructor] = [:]

    public var headerType: TableViewPresentable.Type?

    public var dataCount: Int {
        return data.count
    }

    public var cellType: TableViewPresentable.Type {
        return CellType.self
    }

    public init(title: String?, data: [DataType], configurator: CellConfigurator?, selectionHandler: SelectionHandler?, heightConfigurator: HeightConfigurator? = nil, headerType: TableViewPresentable.Type? = nil) {
        self.data = data
        self.selectionHandler = selectionHandler
        self.configurator = configurator
        self.title = title
        self.heightConfigurator = heightConfigurator
        self.headerType = headerType
    }

    public func configure(cell: UITableViewCell, index: Int) {
        configurator?(cell as! CellType, index, data[index])
    }

    public func handle(selection index: Int) {
        selectionHandler?(index, data[index])
    }

    public func heightForCell(atIndex index: Int) -> CGFloat {
        return heightConfigurator?(index, data[index]) ?? CellType.staticHeight
    }
}
