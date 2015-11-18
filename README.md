# ChatMachine 0.3.1
This is a practice of a chatting app from this [tutorial](http://www.jianshu.com/p/1f93e0fec8a5) 

# Requirements
* Xcode 7 
* Swift 2.1
* iOS 9.0+


# Updated CocoaPod:
```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'Alamofire','~> 3.1’
pod 'SnapKit', '~> 0.16.0'
pod 'Parse','~>1.9.1’
pod 'ParseUI','~>1.1.3'
```

## [Tutorial 1](http://www.jianshu.com/p/1f93e0fec8a5) 
```
Including:
Install cocoaPod
Parse import messages
Swift 2.0
Input ToolBar
...
```
## [Tutorial 2](http://www.jianshu.com/p/f2488a659688)
```
Chatting Interface Design: message bubble, datetime format
SnapKit：用代码设置autolayout
Turing Robot API
...
```
## [Tutorial 3](http://www.jianshu.com/p/a09ceaebe797)
```
query message from Parse,display on UITableView
insert new message on tableView: insertSections/insertRows
updateTextViewHeight()
tableViewScrollToBottonAnimated
Turing Robot API
...
```

## [Tutorial 4](http://www.jianshu.com/p/91545cde4f8d)
```
用KVO(Key-Value Observing)方法优化键盘弹出动画
将同步下载消息改为异步，以减轻主线程的压力
Code:  query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in }
TableView滚动至最新的消息位置 Code：tableViewScrollToBottomAnimated
...
```

## [Tutorial 5](http://www.jianshu.com/p/6bf05564fe27)

