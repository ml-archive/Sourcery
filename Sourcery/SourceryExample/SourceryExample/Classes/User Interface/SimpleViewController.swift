//
//  SimpleViewController.swift
//  SourceryExample
//
//  Created by Dominik Hádl on 29/04/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import UIKit
import Sourcery

class SimpleViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var sourcery: SimpleSourcery<String, BasicCell>?

    let data = ["First row", "Second row", "Another row"]

    override func viewDidLoad() {
        super.viewDidLoad()

        sourcery = SimpleSourcery<String, BasicCell>(tableView: tableView, data: data, configurator: { $0.cell.textLabel?.text = $0.object })
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        var newData: [String] = (sourcery?.data ?? data)
        newData.append("New row")
        sourcery?.updateData(newData: newData)
    }
}

