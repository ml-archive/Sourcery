//
//  CustomHeaderView.swift
//  SourceryExample
//
//  Created by Dominik Hádl on 31/05/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import UIKit
import Sourcery

class CustomHeaderView: UITableViewHeaderFooterView {
    @IBOutlet var customTitleLabel: UILabel!
}

extension CustomHeaderView: TableViewPresentable {
    static var staticHeight: CGFloat {
        return 50.0
    }
}