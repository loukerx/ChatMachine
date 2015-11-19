//
//  LogInViewController.swift
//  ChatMachine
//
//  Created by Yin Hua on 19/11/2015.
//  Copyright © 2015 Yin Hua. All rights reserved.
//

import UIKit
import ParseUI
class LogInViewController: PFLogInViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.logInView?.logo = UIImageView(image: UIImage(named: "logo"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
