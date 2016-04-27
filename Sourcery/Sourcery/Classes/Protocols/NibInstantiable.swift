//
//  NibInstantiable.swift
//  Sourcery
//
//  Created by Dominik Hádl on 27/04/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation

public protocol NibInstantiable: class {
    static func newFromNib<T>() -> T
}