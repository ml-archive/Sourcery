//
//  PagedSection.swift
//  Sourcery
//
//  Created by Dominik Hádl on 27/04/16.
//  Copyright © 2016 Nodes ApS. All rights reserved.
//

import Foundation

// --
// WORK IN PROGRESS
// --

//class PagedSection<DataType, CellType: TableViewPresentable>: NSObject, SectionType {
//
//    typealias PageLoader = ((page: Int, operationQueue: NSOperationQueue, completion: ((totalCount: Int, data: [DataType]) -> Void)) -> Void)
//    typealias SelectionHandler = ((index: Int, object: DataType) -> Void)
//    typealias CellConfigurator = ((cell: CellType, index: Int, object: DataType) -> Void)
//
//    private(set) var data: PagedArray<DataType>?
//    private var selectionHandler: SelectionHandler?
//    private var configurator: CellConfigurator?
//
//    private(set) var title: String?
//
//    // Pagination
//    var preloadMargin: Int? = 10
//    private var pageSize: Int
//    private var pageLoader: PageLoader
//    private var pagesLoading = Set<Int>()
//
//    // Operation queue
//    private let operationQueue = NSOperationQueue()
//
//    var customConstructors: [Int: CellConstructor] = [:]
//
//    var dataCount: Int {
//        return data?.count ?? 0
//    }
//
//    var cellType: TableViewPresentable.Type {
//        return CellType.self
//    }
//
//    private override init() {
//        fatalError("Never instantiate this class directly. Use the init(tableView:pageSize:pageLoader:configurator:selectionHandler:) initializer.")
//    }
//
//    init(title: String?, pageSize: Int, pageLoader: PageLoader, configurator: CellConfigurator, selectionHandler: SelectionHandler?) {
//        self.selectionHandler = selectionHandler
//        self.configurator = configurator
//        self.title = title
//        self.pageLoader   = pageLoader
//        self.pageSize     = pageSize
//        super.init()
//
//        startLoadingPages()
//    }
//
//    // MARK: - Page Control -
//
//    func startLoadingPages() {
//        pageLoader(page: 0, operationQueue: operationQueue, completion: pageLoaderCompletion(page: 0))
//    }
//
//    func resetAndStopLoading() {
//        operationQueue.cancelAllOperations()
//        data = nil
//    }
//
//    // MARK: - Cells -
//
//    func configureCell(cell: UITableViewCell, index: Int) {
//        loadDataIfNeededForRow(index)
//
//        if let object = data?[index] {
//            configurator?(cell: cell as! CellType, index: index, object: object)
//        }
//    }
//
//    func handleSelection(index: Int) {
//        if let object = data?[index] {
//            selectionHandler?(index: index, object: object)
//        }
//    }
//
//    func heightForCellAtIndex(index: Int) -> CGFloat {
//        return CellType.staticHeight
//    }
//
//    // MARK: - Pagination -
//
//    private func pageLoaderCompletion(page page: Int) -> ((totalCount: Int, data: [DataType]) -> Void) {
//        // Mark the page as being loaded
//        pagesLoading.insert(page)
//
//        return { [weak self] (totalCount, data) in
//            guard let weakSelf = self else { return }
//
//            var needsReload = false
//
//            // Create the data array, if not created yet
//            if weakSelf.data == nil {
//                weakSelf.data = PagedArray<DataType>(count: totalCount, pageSize: weakSelf.pageSize)
//                needsReload = true
//            }
//
//            // Set the downloaded elements
//            weakSelf.data?.setElements(data, pageIndex: page)
//
//            // Refresh visible rows in tableview if needed
//            if needsReload {
//                weakSelf.tableView?.reloadData()
//            } else if let indexes = weakSelf.data?.indexes(page), indexPathsToReload = weakSelf.visibleIndexPathsForIndexes(indexes) {
//                weakSelf.tableView?.reloadRowsAtIndexPaths(indexPathsToReload, withRowAnimation: .Automatic)
//            }
//
//            // Remove the page being loaded
//            self?.pagesLoading.remove(page)
//        }
//    }
//
//    private func loadDataIfNeededForRow(row: Int) {
//        // Start loading current page if necessary
//        guard let currentPage = data?.pageNumberForIndex(row) else { return }
//        if needsLoadDataForPage(currentPage) {
//            pageLoader(page: currentPage, operationQueue: operationQueue, completion: pageLoaderCompletion(page: currentPage))
//        }
//
//        // Preload iff preloading enabled
//        guard let preloadMargin = preloadMargin else { return }
//
//        let preloadIndex = row + preloadMargin
//        if preloadIndex < data?.endIndex {
//            guard let preloadPage = data?.pageNumberForIndex(preloadIndex) else { return }
//            if preloadPage > currentPage && needsLoadDataForPage(preloadPage) {
//                pageLoader(page: preloadPage, operationQueue: operationQueue, completion: pageLoaderCompletion(page: preloadPage))
//            }
//        }
//    }
//
//    private func needsLoadDataForPage(page: Int) -> Bool {
//        return data != nil && data?.pages[page] == nil && !pagesLoading.contains(page)
//    }
//
//    // MARK: - Helpers -
//
//    private func visibleIndexPathsForIndexes(indexes: Range<Int>) -> [NSIndexPath]? {
//        return tableView?.indexPathsForVisibleRows?.filter { indexes.contains($0.row) }
//    }
//}