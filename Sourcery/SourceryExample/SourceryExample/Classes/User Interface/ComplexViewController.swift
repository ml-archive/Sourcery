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
                colors: [UIColor.red, UIColor.yellow, UIColor.blue])

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addSection))

        let textSection = Section<String, BasicCell>(title: nil, data: data.texts, configurator: { (cell, index, object) in
            cell.textLabel?.text = object
        }, selectionHandler: nil)
        let colorSection = Section<UIColor, ColorCell>(title: "Colors", data: data.colors, configurator: { (cell, index, object) in
            cell.populateWithColor(color: object)
        }, selectionHandler: nil, headerType: CustomHeaderView.self)
        sourcery = ComplexSourcery(tableView: tableView, sections: [textSection, colorSection], headerConfigurator: { section, header, title in
            if let header = header as? CustomHeaderView {
                header.customTitleLabel.text = title
            }
        })
    }

    @objc func addSection() {
        var sections = sourcery?.sections ?? []
        sections.append(Section<String, BasicCell>(title: "\(sections.count ?? 0 + 1)", data: data.texts, configurator: { (cell, index, object) in
            cell.textLabel?.text = object
        }, selectionHandler: nil))
        sourcery?.update(sections: sections)
    }
}
