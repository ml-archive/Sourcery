//
//  PagedSourcery.swift
//  Sourcery
//
//  Created by Dominik Hádl on 27/04/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import UIKit
import PagedArray

public class PagedSourcery<DataType, CellType: TableViewPresentable>: NSObject, TableController {

    public typealias PageLoader = ((page: Int, operationQueue: NSOperationQueue, completion: ((totalCount: Int, data: [DataType]) -> Void)) -> Void)
    public typealias SelectionHandler = ((index: Int, object: DataType) -> Void)
    public typealias CellConfigurator = ((cell: CellType, index: Int, object: DataType) -> Void)
    public typealias HeaderConfigurator = ((UITableViewHeaderFooterView?) -> Void)

    // MARK: - Properties -
    // MARK: Table View & Data

    public private(set) weak var tableView: UITableView?
    public private(set) var data: PagedArray<DataType>?

    // MARK: Cells

    private var selectionHandler: SelectionHandler?
    private var configurator: CellConfigurator
    private var headerConfigurator: HeaderConfigurator?

    // MARK: Pagination

    /// If your pages are not indexed from 0, then you can manually change the start index.
    /// Doing this will reset the loaded pages and reload everything.
    public var startPageIndex: Int = 0 {
        didSet {
            startLoadingPages()
        }
    }

    /// A preload margin (if specified) will fetch elements in advance by the specified amount.
    public var preloadMargin: Int? = 10

    private var pageSize: Int
    private var pageLoader: PageLoader
    private var pagesLoading = Set<Int>()

    // MARK: Other settings

    /// If enabled, the cell will be automatically deselected (animated)
    /// after `tableView(_:didSelectRowAtIndexPath:)` is called.
    public var autoDeselect = true

    /// Setting a custom height will override the height of all cells to the value specified.
    /// If the value is nil, the `staticHeight` property of each cell will be used instead.
    public var customHeight: CGFloat?

    /// If set, then some UITableView delegate methods will be sent to it.
    public var delegateProxy: TableViewDelegateProxy?

    /// TODO: Documentation
    public var headerType: TableViewPresentable.Type?

    // MARK: Operation queue
    private let operationQueue = NSOperationQueue()

    // MARK: - Init -

    private override init() {
        fatalError("Never instantiate this class directly. Use the init(tableView:pageSize:pageLoader:configurator:selectionHandler:) initializer.")
    }

    public required init(tableView: UITableView, pageSize: Int, pageLoader: PageLoader, configurator: CellConfigurator, selectionHandler: SelectionHandler? = nil, headerConfigurator: HeaderConfigurator? = nil) {
        self.tableView    = tableView
        self.configurator = configurator
        self.pageLoader   = pageLoader
        self.pageSize     = pageSize
        self.selectionHandler = selectionHandler
        self.headerConfigurator = headerConfigurator
        super.init()

        self.tableView?.dataSource = self
        self.tableView?.delegate = self

        startLoadingPages()
    }

    deinit {
        resetAndStopLoading()
    }

    // MARK: - Page Control -

    /**
     Starts loading data for the first page and handling the result accordingly.

     - note: Before starting to load pages everything is reset and data is cleared.
     */
    public func startLoadingPages() {
        resetAndStopLoading()
        pageLoader(page: startPageIndex, operationQueue: operationQueue, completion: pageLoaderCompletion(page: startPageIndex))
    }

    /**
     Cancels all ongoing operations in the operation queue, clears all data a reloads the table view.
     
     - note: You need to manually start loading data after you've called this function.
     */
    public func resetAndStopLoading() {
        // Cancel all ongoing page load operations
        operationQueue.cancelAllOperations()

        // Reset data
        data = nil

        // Reload tableview
        tableView?.reloadData()
    }

    // MARK: - UITableView Data Source & Delegate -

    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.count ?? 0
    }

    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // Custom height if defined, otherwise the cell height
        return customHeight ?? CellType.staticHeight
    }

    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // If we have a header, return its height
        return headerType?.staticHeight ?? 0
    }

    public func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        // If we have a header, return its height
        return headerType?.staticHeight ?? 0
    }

    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // If a header is specified - dequeue, configure and return it
        if let type = headerType {
            let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(type.reuseIdentifier)
            headerConfigurator?(header)
            return header
        }

        return nil
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Dequeue or register the cell
        let cell: CellType = tableView.dequeueCellType(CellType)

        // Load data, if the data for current row is not available
        loadDataIfNeededForRow(indexPath.row)

        // Configure the row as needed, if we have data
        if let object = data?[indexPath.row] {
            configurator(cell: cell, index: indexPath.row, object: object)
        }

        // Return the cell
        return cell as! UITableViewCell
    }

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Deselect row, if auto deselect enabled        
        if autoDeselect { tableView.deselectRowAtIndexPath(indexPath, animated: true) }

        // Call the selection handler, if we have data for row
        if let object = data?[indexPath.row] {
            selectionHandler?(index: indexPath.row, object: object)
        }
    }

    public func scrollViewDidScroll(scrollView: UIScrollView) {
        delegateProxy?.scrollViewDidScroll(scrollView)
    }

    // MARK: - Pagination -

    private func pageLoaderCompletion(page page: Int) -> ((totalCount: Int, data: [DataType]) -> Void) {
        // Mark the page as being loaded
        pagesLoading.insert(page)

        return { [weak self] (totalCount, data) in
            defer {
                // Remove the page being loaded
                self?.pagesLoading.remove(page)
            }

            guard let weakSelf = self else { return }

            if totalCount == 0 {
                weakSelf.resetAndStopLoading()
                return
            }

            var needsReload = false

            // Create the data array, if not created yet
            if weakSelf.data == nil || totalCount != weakSelf.data?.count {
                weakSelf.data = PagedArray<DataType>(count: totalCount, pageSize: weakSelf.pageSize, startPageIndex: weakSelf.startPageIndex)
                needsReload = true
            }

            // Set the downloaded elements
            weakSelf.data?.setElements(data, pageIndex: page)

            // Refresh visible rows in tableview if needed
            if needsReload {
                dispatch_async(dispatch_get_main_queue(), { 
                    weakSelf.tableView?.reloadData()
                })
            } else if let indexes = weakSelf.data?.indexes(page), indexPathsToReload = weakSelf.visibleIndexPathsForIndexes(indexes) {
                dispatch_async(dispatch_get_main_queue(), {
                    weakSelf.tableView?.reloadRowsAtIndexPaths(indexPathsToReload, withRowAnimation: .Automatic)
                })
            }
        }
    }

    private func loadDataIfNeededForRow(row: Int) {
        // Start loading current page if necessary
        guard let currentPage = data?.pageNumberForIndex(row) else { return }
        if needsLoadDataForPage(currentPage) {
            pageLoader(page: currentPage, operationQueue: operationQueue, completion: pageLoaderCompletion(page: currentPage))
        }

        // Preload iff preloading enabled
        guard let preloadMargin = preloadMargin else { return }

        let preloadIndex = row + preloadMargin
        if preloadIndex < data?.endIndex {
            guard let preloadPage = data?.pageNumberForIndex(preloadIndex) else { return }
            if preloadPage > currentPage && needsLoadDataForPage(preloadPage) {
                pageLoader(page: preloadPage, operationQueue: operationQueue, completion: pageLoaderCompletion(page: preloadPage))
            }
        }
    }

    private func needsLoadDataForPage(page: Int) -> Bool {
        return data != nil && data?.pages[page] == nil && !pagesLoading.contains(page)
    }
    
    // MARK: - Helpers -
    
    private func visibleIndexPathsForIndexes(indexes: Range<Int>) -> [NSIndexPath]? {
        return tableView?.indexPathsForVisibleRows?.filter { indexes.contains($0.row) }
    }
}