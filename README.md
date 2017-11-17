# 🔮 Sourcery

[![Travis](https://img.shields.io/travis/nodes-ios/Sourcery.svg)](https://travis-ci.org/nodes-ios/Sourcery)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/nodes-ios/Sourcery/blob/master/LICENSE)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Plaform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)

Sourcery is a framework that simplifies `UITableView` setup and makes your life easier by not requiring you to write hundreds of lines of code just to setup simple (and complex) table views. It contains multiple classes that can't be used for different purposes, ranging from displaying search results to complex table views consisting of many cells and different cell types.

## Why Sourcery?
There are plenty of other frameworks available, but none like this. Why should you use it?

* Setup`UITableView`in 10 lines of code? **Yes.**
* Custom cells with strong typed dequeueing and automatic NIB registration? **Of course.**
* Pagination with great UX and and operation queue for loading data? **Yeah!**
* More? **Absolutely.**

## 💸 What does it cost?

⌨️ **10 lines of code in initiallizer**  
⛓ **1 strong reference**

## 📝 Requirements

* iOS 8.0+

## 📦 Installation

### Carthage
~~~
For Swift 2.2 use:
github "nodes-ios/Sourcery" ~> 0.2

For Swift 3.0.1 use:
github "nodes-ios/Sourcery" == 1.0.2

For Swift 4+ use:
github "nodes-ios/Sourcery" ~> 1.0.3
~~~

## 💻 Usage


Your tabel view cells must implement the `TableViewPresentable` protocol. The protocol uses default implementations for most of its methods, but you still need to implement the `staticHeight`. In your cell (let's say it's a `BasicCell`), do something like:

```swift
extension BasicCell: TableViewPresentable {
    static var staticHeight: CGFloat {
        return 44.0
    }
}
```

There are 3 types of Sourcery you can make: `SimpleSourcery`, `ComplexSourcery` and `PagedSourcery`.

####SimpleSourcery

Let's say you want to create a table that has BasicCell cells and String as the type in the data source.

```swift
var textSourcery : SimpleSourcery<String, BasicCell>?	// you need a strong reference to this
let textDataSource = ["One", "Two", "Three"]
```

Instantiate your `SimpleSourcery`:

```swift
        textSourcery = SimpleSourcery<String, BasicCell>(tableView: tableView, data: textDataSource, configurator: { (cell, index, object) in
            cell.textLabel?.text = object
        })
```
In this case, `cell` is a BasicCell, `index` is the index of the element in the `textDataSource` and `object` is the String in the data source for that index. In the configurator, you just configure the cell to show the object in your data source.

####ComplexSourcery

A `ComplexSourcery` is made of Sections. Each `Section` is similar to a `SimpleSourcery`.

Let's say you want to create a table that has 2 Sections, one with `BasicCell` and one with `ImageCell`.

Create the data sources:

```swift
let textDataSource = ["One", "Two", "Three"]
let imageDataSource = [UIImage(named: "1")!, UIImage(named: "2")!, UIImage(named: "3")!, UIImage(named: "4")!, UIImage(named: "5")!]
```

Have a strong reference to your `ComplexSourcery`:

```swift
var complexSourcery : ComplexSourcery?
```

Create the Sections:

```swift
let textSection = Section<String, BasicCell>(title: "Text", data: textDataSource, configurator: { (cell, index, object) in
	    cell.textLabel?.text = object
	    }, selectionHandler: nil)

let imageSection = Section<UIImage, ImageCell>(title: "Images", data: imageDataSource, configurator: { (cell, index, object) in
	    cell.cellImageView.image = object
	    }, selectionHandler: nil)
```

Create the `ComplexSourcery`:

```swift
complexSourcery = ComplexSourcery(tableView: tableView, sections: [textSection, imageSection])
```

If you want to also handle the selection of a cell, you just add the selectionHandler to each Section. For example:

```swift
let clickableTextSection = Section<String, BasicCell>(title: "Text", data: textDataSource, configurator: { (cell, index, object) in
            cell.textLabel?.text = object
            }, selectionHandler: { (index, object) in
                UIAlertView(title: nil, message: object, delegate: nil, cancelButtonTitle: "Ok").show()
        })
```

And also add that section to your `ComplexSourcery`:

```swift
complexSourcery = ComplexSourcery(tableView: tableView, sections: [textSection, imageSection, clickableSection])
```

Now your table will have three sections, one with text, one with images, and another one that looks exactly like the first one (that's how we configured it) and also shows an alert when you press on the rows.

####PagedSourcery

`PagedSourcery` can be used for tables that get data from an external API, paginated. It implements a very smooth scrolling experience, avoiding the annoying bouncy scrolling when you reach the bottom, while the next page is loading.

The way to use it is very similar to a `SimpleSourcery`, but `PagedSourcery` also provides an operation queue where you add the operations to fetch the next page of data.

For example, let's say you get a list of beers from an API.

```swift
var sourcery: PagedSourcery<Beer, BasicCell>? 		// strong reference to this one
var beers = []
```

```swift
sourcery = PagedSourcery<Beer, BasicCell>(tableView: tableView, pageSize: 50, pageLoader: { (page, operationQueue, completion) in
            operationQueue.addOperationWithBlock({

                ConnectionManager.fetchBeers(page, completion: { (response) in

                    switch response.result {
                    case .Success(let beerResponse):
                        completion(totalCount: beerResponse.totalResults, data:beerResponse.beers)
                    case .Failure(_):
                        print("error")

                    }

                    })
                })
            }, configurator: { $0.cell.textLabel?.text = $0.object.name })
        sourcery?.startPageIndex = 1
        sourcery?.preloadMargin = nil
```

And that's it. In less than 15 lines of code, you have a UITableView that gets its data from a web API, paginated, with a very smooth scrolling experience.

Have a look at the [example project](Sourcery/SourceryExample) or at [the other demo project](https://github.com/mariusc/SourceryDemo).


## 👥 Credits
Made with ❤️ at [Nodes](http://nodesagency.com).

## 📄 License
**Sourcery** is available under the MIT license. See the [LICENSE](https://github.com/nodes-ios/Sourcery/blob/master/LICENSE) file for more info.
