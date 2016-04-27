//
//  SectionType.swift
//  Sourcery
//
//  Created by Dominik Hádl on 27/04/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import UIKit

public typealias CellConstructor = ((tableView: UITableView, index: Int) -> UITableViewCell)

public protocol SectionType {
    var dataCount: Int { get }
    var cellType: TableViewPresentable.Type { get }
    var title: String? { get }

    var customConstructors: [Int: CellConstructor] { get set }

    func heightForCellAtIndex(index: Int) -> CGFloat
    func configureCell(cell: UITableViewCell, index: Int)
    func handleSelection(index: Int)
}
