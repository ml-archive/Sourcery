//
//  BasicCell.swift
//  SourceryExample
//
//  Created by Dominik Hádl on 29/04/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import UIKit
import Sourcery

class BasicCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        textLabel?.text = "Loading..."
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = "Loading..."
    }

}

extension BasicCell: TableViewPresentable {
    static var staticHeight: CGFloat {
        return 44.0
    }
}