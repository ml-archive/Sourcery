//
//  Extensions.swift
//  Sourcery
//
//  Created by Dominik Hádl on 27/04/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import UIKit

// MARK: - UITableView -

public extension UITableView {

    // MARK: Register

    public func register(cellType: TableViewPresentable.Type) {
        if cellType.loadsFromNib {
            self.register(cellType.nib, forCellReuseIdentifier: cellType.reuseIdentifier)
        } else {
            self.register(cellType, forCellReuseIdentifier: cellType.reuseIdentifier)
        }
    }

    public func register<T>(cellType: T.Type) where T: TableViewPresentable {
        if cellType.loadsFromNib {
            self.register(cellType.nib, forCellReuseIdentifier: cellType.reuseIdentifier)
        } else {
            self.register(cellType, forCellReuseIdentifier: cellType.reuseIdentifier)
        }
    }

    public func register(cellTypes: [TableViewPresentable.Type]) {
        for cell in cellTypes {
            register(cellType: cell)
        }
    }

    // MARK: Dequeue

    public func registerAndDequeueCell(withCellType cellType: TableViewPresentable.Type) -> UITableViewCell {
        // First register
        register(cellType: cellType)

        // Try to get cell or fail miserably
        guard let cell = self.dequeueReusableCell(withIdentifier: cellType.reuseIdentifier) else {
            fatalError("Cell registration and dequeue failed. Please check that " +
                       "your NIB file exists or your class is available and set up correctly.")
        }

        // Return cell
        return cell
    }

    public func dequeue<T>(cellType: TableViewPresentable.Type) -> T where T: TableViewPresentable {
        var requestedCell = self.dequeueReusableCell(withIdentifier: cellType.reuseIdentifier) as? T
        requestedCell     = requestedCell ?? registerAndDequeueCell(withCellType: cellType) as? T

        // This 'should never happen'
        guard let cell = requestedCell else {
            fatalError("Internatl inconsistency error. If you got this far," +
                       " there is something seriously wrong with Swift.")
        }

        return cell
    }

    public func dequeueDefault(cellType: TableViewPresentable.Type) -> UITableViewCell {
        let cell = self.dequeueReusableCell(withIdentifier: cellType.reuseIdentifier)
        return cell ?? registerAndDequeueCell(withCellType: cellType)
    }

    // MARK: Header & Footer

    public func registerHeaderFooterView(viewType: TableViewPresentable.Type) {
        if viewType.loadsFromNib {
            self.register(viewType.nib, forHeaderFooterViewReuseIdentifier: viewType.reuseIdentifier)
        } else {
            self.register(viewType, forHeaderFooterViewReuseIdentifier: viewType.reuseIdentifier)
        }
    }

    public func registerAndDequeueHeaderFooterView(viewType: TableViewPresentable.Type) -> UITableViewHeaderFooterView? {
        // First register
        registerHeaderFooterView(viewType: viewType)

        // Try to get cell or fail miserably
        guard let view = self.dequeueReusableHeaderFooterView(withIdentifier: viewType.reuseIdentifier) else {
            fatalError("Header/Footer view registration and dequeue failed. Please check that " +
                "your NIB file exists or your class is available and set up correctly.")
        }

        // Return cell
        return view
    }

    public func dequeueHeaderFooterView(_ viewType: TableViewPresentable.Type) -> UITableViewHeaderFooterView? {
        var requestedView = self.dequeueReusableHeaderFooterView(withIdentifier: viewType.reuseIdentifier)
        requestedView     = requestedView ?? registerAndDequeueHeaderFooterView(viewType: viewType)

        // This 'should never happen'
        guard let view = requestedView else {
            fatalError("Internatl inconsistency error. If you got this far," +
                " there is something seriously wrong with Swift.")
        }

        return view
    }
}
