//
//  PagedViewController.swift
//  SourceryExample
//
//  Created by Dominik Hádl on 29/04/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import UIKit
import Sourcery

class PagedViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var sourcery: PagedSourcery<String, BasicCell>?

    let data = [["First row [0]", "Second row [0]", "Another row [0]"],
                ["First row [1]", "Second row [1]", "Another row [1]"],
                ["First row [2]", "Second row [2]", "Another row [2]"],
                ["First row [3]", "Second row [3]", "Another row [3]"],
                ["First row [4]", "Second row [4]", "Another row [4]"],
                ["First row [5]", "Second row [5]", "Another row [5]"],
                ["First row [6]", "Second row [6]", "Another row [6]"],
                ["First row [7]", "Second row [7]", "Another row [7]"],
                ["First row [8]", "Second row [8]", "Another row [8]"]]

    override func viewDidLoad() {
        super.viewDidLoad()

        let totalCount = data.reduce(0, combine: { $0.0 + $0.1.count })

        sourcery = PagedSourcery<String, BasicCell>(tableView: tableView, pageSize: 3, pageLoader: { (page, operationQueue, completion) in
            operationQueue.addOperationWithBlock({
                completion(totalCount: totalCount, data: self.data[page])
            })
            }, configurator: { $0.cell.textLabel?.text = $0.object })
    }
}
