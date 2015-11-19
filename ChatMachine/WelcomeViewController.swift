//
//  WelcomeViewController.swift
//  ChatMachine
//
//  Created by Yin Hua on 19/11/2015.
//  Copyright © 2015 Yin Hua. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class WelcomeViewController: UIViewController,PFSignUpViewControllerDelegate,PFLogInViewControllerDelegate {

    var loginVC:LogInViewController!
    var signUpVC:SignUpViewController!
    var logo:UIImageView!
    var welcomeLabel:UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = UIColor.whiteColor()
        self.navigationController?.navigationBarHidden = true
        logo = UIImageView(image: UIImage(named: "logo"))
        logo.center = CGPoint(x: view.center.x, y: view.center.y - 50)
        welcomeLabel = UILabel(frame: CGRect(x: view.center.x - 150/2, y: view.center.y + 20, width: 150, height: 50))
        welcomeLabel.font = UIFont.systemFontOfSize(22)
        welcomeLabel.textColor = UIColor(red:0.11, green:0.55, blue:0.86, alpha:1)
        welcomeLabel.textAlignment = .Center
        view.addSubview(welcomeLabel)
        
        view.addSubview(logo)
        
        
        
        
    }

    override func viewWillAppear(animated: Bool) {
        if (PFUser.currentUser() != nil){
            self.welcomeLabel.text = "欢迎 \(PFUser.currentUser()!.username!)!"
            delay(2.0, completion: { () -> () in
                let  chatVC = ChatViewController()
                chatVC.title = "灵灵"
                let naviVC  =  UINavigationController(rootViewController: chatVC)
                self.presentViewController(naviVC, animated: true, completion: nil)
            })
        }else{
            self.welcomeLabel.text = "未登录"
            delay(2.0) { () -> () in
                self.loginVC = LogInViewController()
                self.loginVC.delegate = self
                self.signUpVC = SignUpViewController()
                self.signUpVC.delegate = self
                self.loginVC.signUpController = self.signUpVC
                self.presentViewController(self.loginVC, animated: true, completion: nil)
            }
            
            
        }
        
    }

    func delay(seconds: Double, completion:()->()) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
        
        dispatch_after(popTime, dispatch_get_main_queue()) {
            completion()
        }
    }
    
    //MARK: - LogInView Delegate
    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
        if (!username.isEmpty && !password.isEmpty )
        {
            return true
        }
        UIAlertView(title: "缺少信息", message: "请补全缺少的信息", delegate: self, cancelButtonTitle:"确定").show()
        
        
        return false
    }
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        
        print("登录错误")
        
        
    }

    //MARK: - SignUpView Delegate
    func signUpViewController(signUpController: PFSignUpViewController, shouldBeginSignUp info: [NSObject : AnyObject]) -> Bool {
        
        var infomationComplete = true
        for key in info.values {
            let field = key as! String
            if (field.isEmpty){
                infomationComplete = false
                break
            }
        }
        
        if (!infomationComplete){
            
            
            UIAlertView(title: "缺少信息", message: "请补全缺少的信息", delegate: self, cancelButtonTitle:"确定").show()
            
            return false
        }
        return true
    }
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError error: NSError?) {
        print("注册失败")
    }
    
    
    
    

}
