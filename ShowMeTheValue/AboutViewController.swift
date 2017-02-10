//
//  AboutViewController.swift
//  ShowMeTheValue
//
//  Created by David Michaeloff on 1/29/17.
//  Copyright © 2017 David Michaeloff. All rights reserved.
//

import UIKit
import MessageUI

class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var textViewAbout: UITextView!
    
    override func viewDidLayoutSubviews() {
        self.textViewAbout.setContentOffset(CGPoint.zero, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func sendEmail(_ sender: UIButton) {
        sendEmailUsingMFMail()
    }
    
    // This method opens the built-in email app. However, after sending the email, the user finds themselves in 
    // the email app and not returned to the calling application.
    func sendEmailUsingMailToLink() {
        let subject = "Re: Home Estimates Near Me"
        let body = ""
        if let coded = "mailto:michaeloffandassociates@gmail.com?subject=\(subject)&body=\(body)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let emailURL: NSURL = NSURL(string: coded)
        {
            if UIApplication.shared.canOpenURL(emailURL as URL) {
                UIApplication.shared.openURL(emailURL as URL)
            }
        }
    }
    
    // This method uses the MFMailComposeViewController. One advantage here, is that after the email is sent
    // (and the controller is properly dismissed) the user is returned to the calling application.
    func sendEmailUsingMFMail() {
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["michaeloffandassociates@gmail.com"])
        mailComposerVC.setSubject("Re: Home Estimates Near Me")
        mailComposerVC.setMessageBody("", isHTML: false)
        self.present(mailComposerVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
        
        switch result {
        case MFMailComposeResult.sent:
            DispatchQueue.main.async{
                let alertController = UIAlertController(title: "Email Sent", message: "\nThank you!", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        default: ()
        }
    }
}
