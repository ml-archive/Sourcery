//
//  TableViewDelegateProxy.swift
//  Sourcery
//
//  Created by Dominik Hádl on 11/08/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation
import UIKit

public protocol TableViewDelegateProxy: class {
    func scrollViewDidScroll(scrollView: UIScrollView)
}