//
//  TableViewPresentable.swift
//  Sourcery
//
//  Created by Dominik Hádl on 23/02/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import UIKit

public typealias TableController = UITableViewDataSource & UITableViewDelegate

public protocol TableViewPresentable: NibInstantiable {
    static var nib: UINib { get }
    static var reuseIdentifier: String { get }
    static var staticHeight: CGFloat { get }
    static var loadsFromNib: Bool { get }
}

public extension TableViewPresentable {
    public static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    public static func newFromNib<T>() -> T {
        return nib.instantiate(withOwner: nil, options: nil).first as! T
    }

    public static var reuseIdentifier: String {
        return String(describing: self)
    }

    public static var loadsFromNib: Bool {
        return true
    }
}

