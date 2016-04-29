//
//  ComplexViewController.swift
//  SourceryExample
//
//  Created by Dominik Hádl on 29/04/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import UIKit
import Sourcery

class ComplexViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var sourcery: ComplexSourcery?

    let data = (texts: ["First row", "Second row", "Another row"],
                colors: [UIColor.redColor(), UIColor.yellowColor(), UIColor.blueColor()])

    override func viewDidLoad() {
        super.viewDidLoad()

        let textSection = Section<String, BasicCell>(title: nil, data: data.texts, configurator: { $0.cell.textLabel?.text = $0.object }, selectionHandler: nil)
        let colorSection = Section<UIColor, ColorCell>(title: "Colors", data: data.colors, configurator: { $0.cell.populateWithColor($0.object) }, selectionHandler: nil)
        sourcery = ComplexSourcery(tableView: tableView, sections: [textSection, colorSection])
    }
}
