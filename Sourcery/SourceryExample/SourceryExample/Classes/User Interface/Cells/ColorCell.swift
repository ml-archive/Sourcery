//
//  ColorCell.swift
//  SourceryExample
//
//  Created by Dominik Hádl on 29/04/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import UIKit
import Sourcery

class ColorCell: UITableViewCell {

    @IBOutlet private weak var colorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        colorView.backgroundColor = UIColor.lightGray
        colorView.layer.cornerRadius = 2
        selectionStyle = .none
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        colorView.backgroundColor = UIColor.lightGray    }

    func populateWithColor(color: UIColor) {
        colorView.backgroundColor = color
    }
}

extension ColorCell: TableViewPresentable {
    static var staticHeight: CGFloat {
        return 80.0
    }
}
