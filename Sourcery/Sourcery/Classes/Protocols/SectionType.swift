//
//  SectionType.swift
//  Sourcery
//
//  Created by Dominik Hádl on 27/04/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import UIKit

public typealias CellConstructor = ((_ tableView: UITableView, _ index: Int) -> UITableViewCell)

public protocol SectionType {
    var dataCount: Int { get }
    var cellType: TableViewPresentable.Type { get }
    var title: String? { get }

    var customConstructors: [Int: CellConstructor] { get set }
    var headerType: TableViewPresentable.Type? { get set }

    func heightForCell(atIndex index: Int) -> CGFloat
    func configure(cell: UITableViewCell, index: Int)
    func handle(selection index: Int)
}
