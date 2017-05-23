//
//  PagedSourcery.swift
//  Sourcery
//
//  Created by Dominik Hádl on 27/04/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import UIKit
import PagedArray

open class PagedSourcery<DataType, CellType: TableViewPresentable>: NSObject, TableController {

    public typealias PageLoader = ((_ page: Int, _ operationQueue: OperationQueue, _ completion: @escaping ((_ totalCount: Int, _ data: [DataType]) -> Void)) -> Void)
    public typealias SelectionHandler = ((_ index: Int, _ object: DataType) -> Void)
    public typealias CellConfigurator = ((_ cell: CellType, _ index: Int, _ object: DataType) -> Void)
    public typealias HeaderConfigurator = ((UITableViewHeaderFooterView?) -> Void)

    // MARK: - Properties -
    // MARK: Table View & Data

    open fileprivate(set) weak var tableView: UITableView?
    open fileprivate(set) var data: PagedArray<DataType>?

    // MARK: Cells

    fileprivate var selectionHandler: SelectionHandler?
    fileprivate var configurator: CellConfigurator
    fileprivate var headerConfigurator: HeaderConfigurator?

    // MARK: Pagination

    /// If your pages are not indexed from 0, then you can manually change the start index.
    /// Doing this will reset the loaded pages and reload everything.
    open var startPageIndex: Int = 0 {
        didSet {
            startLoadingPages()
        }
    }

    /// A preload margin (if specified) will fetch elements in advance by the specified amount.
    open var preloadMargin: Int? = 10

    fileprivate var pageSize: Int
    fileprivate var pageLoader: PageLoader
    fileprivate var pagesLoading = Set<Int>()

    // MARK: Other settings

    /// If enabled, the cell will be automatically deselected (animated)
    /// after `tableView(_:didSelectRowAtIndexPath:)` is called.
    open var autoDeselect = true

    /// Setting a custom height will override the height of all cells to the value specified.
    /// If the value is nil, the `staticHeight` property of each cell will be used instead.
    open var customHeight: CGFloat?

    /// If set, then some UITableView delegate methods will be sent to it.
    open var delegateProxy: TableViewDelegateProxy?

    /// TODO: Documentation
    open var headerType: TableViewPresentable.Type?

    // MARK: Operation queue
    fileprivate let operationQueue = OperationQueue()

    // MARK: - Init -

    fileprivate override init() {
        fatalError("Never instantiate this class directly. Use the init(tableView:pageSize:pageLoader:configurator:selectionHandler:) initializer.")
    }

    public required init(tableView: UITableView, pageSize: Int, pageLoader: @escaping PageLoader, configurator: @escaping CellConfigurator, selectionHandler: SelectionHandler? = nil, headerConfigurator: HeaderConfigurator? = nil) {
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
    open func startLoadingPages() {
        resetAndStopLoading()
        pageLoader(startPageIndex, operationQueue, pageLoaderCompletion(page: startPageIndex))
    }

    /**
     Cancels all ongoing operations in the operation queue, clears all data a reloads the table view.
     
     - note: You need to manually start loading data after you've called this function.
     */
    open func resetAndStopLoading() {
        // Cancel all ongoing page load operations
        operationQueue.cancelAllOperations()

        // Reset data
        data = nil

        // Reload tableview
        tableView?.reloadData()
    }

    // MARK: - UITableView Data Source & Delegate -

    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.count ?? 0
    }

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Custom height if defined, otherwise the cell height
        return customHeight ?? CellType.staticHeight
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // If we have a header, return its height
        return headerType?.staticHeight ?? 0
    }

    open func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        // If we have a header, return its height
        return headerType?.staticHeight ?? 0
    }

    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // If a header is specified - dequeue, configure and return it
        if let type = headerType {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: type.reuseIdentifier)
            headerConfigurator?(header)
            return header
        }

        return nil
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue or register the cell
        let cell: CellType = tableView.dequeue(cellType: CellType.self)

        // Load data, if the data for current row is not available
        loadDataIfNeeded(forRow: indexPath.row)

        // Configure the row as needed, if we have data
        if let object = data?[indexPath.row] {
            configurator(cell, indexPath.row, object)
        }

        // Return the cell
        return cell as! UITableViewCell
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect row, if auto deselect enabled        
        if autoDeselect { tableView.deselectRow(at: indexPath, animated: true) }

        // Call the selection handler, if we have data for row
        if let object = data?[indexPath.row] {
            selectionHandler?(indexPath.row, object)
        }
    }

    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegateProxy?.scrollViewDidScroll(scrollView)
    }

    // MARK: - Pagination -

    fileprivate func pageLoaderCompletion(page: Int) -> ((_ totalCount: Int, _ data: [DataType]) -> Void) {
        // Mark the page as being loaded
        pagesLoading.insert(page)

        return { [weak self] (totalCount, data) in
            defer {
                // Remove the page being loaded
                
                let _ = self?.pagesLoading.remove(page)
            }

            guard let weakSelf = self else { return }

            if totalCount == 0 {
                weakSelf.resetAndStopLoading()
                return
            }

            var needsReload = false

            // Create the data array, if not created yet
            if weakSelf.data == nil || totalCount != weakSelf.data?.count {
                weakSelf.data = PagedArray<DataType>(count: totalCount, pageSize: weakSelf.pageSize, startPage: weakSelf.startPageIndex)
                needsReload = true
            }

            // Set the downloaded elements
            weakSelf.data?.set(data, forPage: page)

            // Refresh visible rows in tableview if needed
            if needsReload {
                DispatchQueue.main.async(execute: { 
                    weakSelf.tableView?.reloadData()
                })
            } else if let indexes = weakSelf.data?.indexes(for: page), let indexPathsToReload = weakSelf.visibleIndexPaths(forIndexes: indexes) {
                DispatchQueue.main.async(execute: {
                    weakSelf.tableView?.reloadRows(at: indexPathsToReload, with: .automatic)
                })
            }
        }
    }

    fileprivate func loadDataIfNeeded(forRow row: Int) {
        // Start loading current page if necessary
        guard let currentPage = data?.page(for: row) else { return }
        if needsLoadData(forPage: currentPage) {
            pageLoader(currentPage, operationQueue, pageLoaderCompletion(page: currentPage))
        }

        // Preload iff preloading enabled
        guard let preloadMargin = preloadMargin else { return }

        let preloadIndex = row + preloadMargin
        if preloadIndex < (data?.endIndex)! {
            guard let preloadPage = data?.page(for: preloadIndex) else { return }
            if preloadPage > currentPage && needsLoadData(forPage: preloadPage) {
                pageLoader(preloadPage, operationQueue, pageLoaderCompletion(page: preloadPage))
            }
        }
    }

    fileprivate func needsLoadData(forPage page: Int) -> Bool {
        return data != nil && data?.elements[page] == nil && !pagesLoading.contains(page)
    }
    
    // MARK: - Helpers -
    
    fileprivate func visibleIndexPaths(forIndexes indexes: CountableRange<Int>) -> [IndexPath]? {
        return tableView?.indexPathsForVisibleRows?.filter { indexes.contains($0.row) }
    }
}
