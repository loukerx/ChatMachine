//
//  ChatViewController.swift
//  ChatMachine
//
//  Created by Yin Hua on 3/11/2015.
//  Copyright © 2015 Yin Hua. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import Alamofire
import SnapKit

let messageFontSize: CGFloat = 17
let toolBarMinHeight: CGFloat = 44
let textViewMaxHeight: (portrait: CGFloat, landscape: CGFloat) = (portrait: 272, landscape: 90)


class InputTextView: UITextView {
    
    
    
}

class ChatViewController: UITableViewController, UITextViewDelegate {

    //MARK: - Variables
    var messages:[[Message]] = [[]]
    
    
    //MARK: - Outlets
    var toolBar: UIToolbar!
    var textView: UITextView!
    var sendButton: UIButton!
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        tableView.registerClass(MessageSentDateTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(MessageSentDateTableViewCell))
        
        self.tableView.keyboardDismissMode = .Interactive
        self.tableView.estimatedRowHeight = 44
        //由于tableView底部有一个输入框，因此会遮挡cell，所以要将tableView的内容inset增加一些底部位移:
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom:toolBarMinHeight, right: 0)
        self.tableView.separatorStyle = .None
        
        self.initData()
  
        
    }

    func initData(){
        var index = 0
        var section = 0
        var currentDate:NSDate?
        //1
        let query:PFQuery = PFQuery(className:"Messages")
        query.orderByAscending("sentDate")
        //2
        
        do {
            
            let myObjects = try query.findObjects()

            for object in myObjects {// query.findObjects() {
                let message = Message(incoming: object["incoming"] as! Bool, text: object["text"] as! String, sentDate: object["sentDate"] as! NSDate)
                
                if index == 0{
                    currentDate = message.sentDate
                }
                let timeInterval = message.sentDate.timeIntervalSinceDate(currentDate!)
                
                //3
                if timeInterval < 120{
                    messages[section].append(message)
                }else{
                    section++
                    messages.append([message])
                    
                    
                }
                currentDate = message.sentDate
                index++
            }
            
        } catch let error as NSError {
            print(error)
        }
     
    }
    
    
    
    //MARK: - TableView DataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return messages.count
        
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages[section].count + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            
            let cellIdentifier = NSStringFromClass(MessageSentDateTableViewCell)
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier,forIndexPath: indexPath) as! MessageSentDateTableViewCell
            let message = messages[indexPath.section][0]
            
            cell.sentDateLabel.text = formatDate(message.sentDate)
            
            return cell
            
        }else{
            let cellIdentifier = NSStringFromClass(MessageBubbleTableViewCell)
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MessageBubbleTableViewCell!
            if cell == nil {
                
                cell = MessageBubbleTableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
            }
            
            let message = messages[indexPath.section][indexPath.row - 1]
            
            cell.configureWithMessage(message)
            
            return cell
        }
        
    }
    
    func formatDate(date: NSDate) -> String {
        let calendar = NSCalendar.currentCalendar()
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "zh_CN")
        
        let last18hours = (-18*60*60 < date.timeIntervalSinceNow)
        let isToday = calendar.isDateInToday(date)

        let isLast7Days = (calendar.compareDate(NSDate(timeIntervalSinceNow: -7*24*60*60), toDate: date, toUnitGranularity:.Day) == NSComparisonResult.OrderedAscending)
        
        if last18hours || isToday {
            dateFormatter.dateFormat = "a HH:mm"
        } else if isLast7Days {
            dateFormatter.dateFormat = "MM月dd日 a HH:mm EEEE"
        } else {
            dateFormatter.dateFormat = "YYYY年MM月dd日 a HH:mm"
            
        }
        return dateFormatter.stringFromDate(date)
    }
    
    
    //MARK: - UITableView Delegate
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! MessageBubbleTableViewCell
        if selectedCell.url != ""{
            let url = NSURL(string: selectedCell.url)
            UIApplication.sharedApplication().openURL(url!)
        }
        return nil
    }
    
    
    //MARK: - Keyboard View
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override var inputAccessoryView: UIView! {
        
        get {
            if toolBar == nil {
                
                toolBar = UIToolbar(frame: CGRectMake(0, 0, 0, toolBarMinHeight-0.5))
                
                textView = InputTextView(frame: CGRectZero)
                textView.backgroundColor = UIColor(white: 250/255, alpha: 1)
                textView.delegate = self
                textView.font = UIFont.systemFontOfSize(messageFontSize)
                textView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 205/255, alpha:1).CGColor
                textView.layer.borderWidth = 0.5
                textView.layer.cornerRadius = 5
                //            textView.placeholder = "Message"
                textView.scrollsToTop = false
                textView.textContainerInset = UIEdgeInsetsMake(4, 3, 3, 3)
                toolBar.addSubview(textView)
                
                sendButton = UIButton(type: .System)//.buttonWithType(.System) as! UIButton
                sendButton.enabled = false
                sendButton.titleLabel?.font = UIFont.boldSystemFontOfSize(17)
                sendButton.setTitle("发送", forState: .Normal)
                sendButton.setTitleColor(UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1), forState: .Disabled)
                sendButton.setTitleColor(UIColor(red: 0.05, green: 0.47, blue: 0.91, alpha: 1.0), forState: .Normal)
                sendButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
                sendButton.addTarget(self, action: "sendAction", forControlEvents: UIControlEvents.TouchUpInside)//add Button Action
                toolBar.addSubview(sendButton)
                
                // 对组件进行Autolayout设置
                
                textView.translatesAutoresizingMaskIntoConstraints = false
                sendButton.translatesAutoresizingMaskIntoConstraints = false
                
                textView.snp_makeConstraints(closure: { (make) -> Void in
                    make.left.equalTo(self.toolBar.snp_left).offset(8)
                    make.top.equalTo(self.toolBar.snp_top).offset(7.5)
                    make.right.equalTo(self.sendButton.snp_left).offset(-2)
                    make.bottom.equalTo(self.toolBar.snp_bottom).offset(-8)
                
                })
                
                sendButton.snp_makeConstraints(closure: { (make) -> Void in
                    make.right.equalTo(self.toolBar.snp_right)
                    make.bottom.equalTo(self.toolBar.snp_bottom).offset(-4.5)
                })
                
            }
            return toolBar
        }
        
        
    }
    

    func sendAction() {
        
        let question = textView.text
        //1
        messages.append([Message(incoming: false, text: question, sentDate: NSDate())])
        textView.text = nil
        updateTextViewHeight()
        sendButton.enabled = false
        //2
        let lastSection = tableView.numberOfSections
        tableView.beginUpdates()
        tableView.insertSections(NSIndexSet(index: lastSection), withRowAnimation:.Automatic)
        tableView.insertRowsAtIndexPaths([
            NSIndexPath(forRow: 0, inSection: lastSection),
            NSIndexPath(forRow: 1, inSection: lastSection)
            ], withRowAnimation: .Automatic)
        tableView.endUpdates()
        tableViewScrollToBottomAnimated(true)
        
        
        let url = NSURL(string: api_url)!
        
        let parameters = [
            "key":api_key,
            "info":question,
            "userid":userId
        ]
        
        
        Alamofire.request(.GET, url, parameters: parameters).responseJSON(options: NSJSONReadingOptions.MutableContainers) { response in
            
            
            if let JSON = response.result.value {
                print(JSON)
                
                if let text = JSON.objectForKey("text") as? String{
//                    self.messages[lastSection].append(Message(incoming: true, text:text, sentDate: NSDate()))
                    
                    
                    if let url = JSON.objectForKey("url") as? String{
                        let message = Message(incoming: true, text:text+"\n(点击该消息打开查看)", sentDate: NSDate())
                        message.url = url
                        self.messages[lastSection].append(message)
                    }else{
                        let message = Message(incoming: true, text:text, sentDate: NSDate())
                        self.messages[lastSection].append(message)
                    }
                    
                    
                    
                    self.tableView.beginUpdates()
                    self.tableView.insertRowsAtIndexPaths([
                        NSIndexPath(forRow: 2, inSection: lastSection)
                        ], withRowAnimation: .Automatic)
                    self.tableView.endUpdates()
                    self.tableViewScrollToBottomAnimated(true)
                }
            }
        }
    }
    
    func updateTextViewHeight() {
        let oldHeight = textView.frame.height
 
        //deperated in iOS 9
        let maxHeight = UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) ? textViewMaxHeight.portrait : textViewMaxHeight.landscape
        var newHeight = min(textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.max)).height, maxHeight)
        #if arch(x86_64) || arch(arm64)
            newHeight = ceil(newHeight)
        #else
            newHeight = CGFloat(ceilf(newHeight.native))
        #endif
        if newHeight != oldHeight {
            toolBar.frame.size.height = newHeight+8*2-0.5
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        updateTextViewHeight()
        sendButton.enabled = textView.hasText()
    }
    
    func tableViewScrollToBottomAnimated(animated: Bool) {
        
        let numberOfSections = messages.count
        let numberOfRows = messages[numberOfSections - 1].count
        if numberOfRows > 0 {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow:numberOfRows, inSection: numberOfSections - 1), atScrollPosition: .Bottom, animated: animated)
        }
    }
}
