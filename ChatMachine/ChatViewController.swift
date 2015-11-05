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
        
        
        //Fake Message
        messages = [
            [
                Message(incoming: true, text: "你叫什么名字？", sentDate: NSDate(timeIntervalSinceNow: -12*60*60*24)),
                Message(incoming: false, text: "我叫灵灵，聪明又可爱的灵灵", sentDate: NSDate(timeIntervalSinceNow:-12*60*60*24))
            ],
            [
                Message(incoming: true, text: "你爱不爱我？", sentDate: NSDate(timeIntervalSinceNow: -6*60*60*24 - 200)),
                Message(incoming: false, text: "爱你么么哒", sentDate: NSDate(timeIntervalSinceNow: -6*60*60*24 - 100))
            ],
            [
                Message(incoming: true, text: "北京今天天气", sentDate: NSDate(timeIntervalSinceNow: -60*60*18)),
                Message(incoming: false, text: "北京:08/30 周日,19-27° 21° 雷阵雨转小雨-中雨 微风小于3级;08/31 周一,18-26° 中雨 微风小于3级;09/01 周二,18-25° 阵雨 微风小于3级;09/02 周三,20-30° 多云 微风小于3级", sentDate: NSDate(timeIntervalSinceNow: -60*60*18))
            ],
            [
                Message(incoming: true, text: "你在干嘛", sentDate: NSDate(timeIntervalSinceNow: -60)),
                Message(incoming: false, text: "我会逗你开心啊", sentDate: NSDate(timeIntervalSinceNow: -65))
            ],
        ]
        
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
//        let aaa = calendar.compareDate(NSDate(timeIntervalSinceNow: -7*24*60*60), toDate: date, toUnitGranularity: .Day)
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
                sendButton.addTarget(self, action: "sendAction", forControlEvents: UIControlEvents.TouchUpInside)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
