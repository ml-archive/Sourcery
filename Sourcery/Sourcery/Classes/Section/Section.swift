//
//  Section.swift
//  Sourcery
//
//  Created by Dominik Hádl on 24/04/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import UIKit

public struct Section<DataType, CellType: TableViewPresentable>: SectionType {

    public typealias SelectionHandler = ((index: Int, object: DataType) -> Void)
    public typealias CellConfigurator = ((cell: CellType, index: Int, object: DataType) -> Void)
    public typealias HeightConfigurator = ((index: Int, object: DataType) -> CGFloat)

    public private(set) var data = [DataType]()
    private var selectionHandler: SelectionHandler?
    private var configurator: CellConfigurator?
    private var heightConfigurator: HeightConfigurator?

    public private(set) var title: String?

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

    public func configureCell(cell: UITableViewCell, index: Int) {
        configurator?(cell: cell as! CellType, index: index, object: data[index])
    }

    public func handleSelection(index: Int) {
        selectionHandler?(index: index, object: data[index])
    }

    public func heightForCellAtIndex(index: Int) -> CGFloat {
        return heightConfigurator?(index: index, object: data[index]) ?? CellType.staticHeight
    }
}