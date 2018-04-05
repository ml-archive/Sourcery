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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSourcery()
    }

    func setupSourcery() {
        let totalCount = data.reduce(0, { value, element in
            value + element.count
        })

        sourcery = PagedSourcery<String, BasicCell>(tableView: tableView, pageSize: 3, pageLoader: {
            [weak self] (page, operationQueue, completion) in
                operationQueue.addOperation { [weak self] in
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(500), execute: {
                        DispatchQueue.main.async {
                            guard let strongSelf = self else { return }
                            completion(totalCount, strongSelf.data[page])
                        }
                    })
                }
            }, configurator: { (cell, index, object) in
                cell.textLabel?.text = object
        })
        sourcery?.preloadMargin = nil
    }
}
