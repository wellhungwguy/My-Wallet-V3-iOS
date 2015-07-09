//
//  BackupWordsViewController.swift
//  Blockchain
//
//  Created by Sjors Provoost on 19-05-15.
//  Copyright (c) 2015 Qkos Services Ltd. All rights reserved.
//

import UIKit

class BackupWordsViewController: UIViewController, SecondPasswordDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var wordsScrollView: UIScrollView?
    @IBOutlet weak var wordsPageControl: UIPageControl?
    @IBOutlet weak var wordsProgressLabel: UILabel?
    @IBOutlet weak var wordLabel: UILabel?
    @IBOutlet weak var screenShotWarningLabel: UILabel?
    
    @IBOutlet weak var verifyButton: UIButton?

    var wallet : Wallet?
    var wordLabels: [UILabel]?
    var isVerifying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        verifyButton?.clipsToBounds = true
        verifyButton?.layer.cornerRadius = Constants.Measurements.BackupButtonCornerRadius
        
        wallet!.addObserver(self, forKeyPath: "recoveryPhrase", options: .New, context: nil)
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()

        if wallet!.needsSecondPassword(){
            self.performSegueWithIdentifier("secondPasswordForBackup", sender: self)
        } else {
            wallet!.getRecoveryPhrase(nil)
        }
        
        wordLabel!.text = ""
        
        updateCurrentPageLabel(0)
        
        wordsScrollView!.clipsToBounds = false
        wordsScrollView!.contentSize = CGSizeMake(12 * wordLabel!.frame.width, wordLabel!.frame.height)

        wordLabels = [UILabel]()
        wordLabels?.insert(wordLabel!, atIndex: 0)
        var i: CGFloat = 0
        for i in 1 ..< 12 {
            let offset: CGFloat = CGFloat(i) * wordLabel!.frame.width
            let x: CGFloat = wordLabel!.frame.origin.x + offset
            let label = UILabel(frame: CGRectMake(x, wordLabel!.frame.origin.y, wordLabel!.frame.size.width, wordLabel!.frame.size.height))
            label.adjustsFontSizeToFitWidth = true
            label.font = wordLabel!.font
            label.textColor = wordLabel!.textColor
            label.textAlignment = wordLabel!.textAlignment

            wordLabel!.superview?.addSubview(label)
            
            wordLabels?.append(label)
        }
    }
    
    func updateCurrentPageLabel(page: Int) {
        wordsProgressLabel!.text = NSLocalizedString(NSString(format: "Word %@ of %@", String(page + 1), String(12)) as String, comment: "")
        if let count = wordLabels?.count {
            if wordsPageControl!.currentPage == count-1 {
                verifyButton?.enabled = true;
                verifyButton?.backgroundColor = Constants.Colors.BlockchainBlue
                verifyButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            }
        }
    }
    
    // MARK: - Words Scrollview
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Determine page number:
        let pageWidth = scrollView.frame.size.width
        let fractionalPage = Float(scrollView.contentOffset.x / pageWidth)
        let page: Int = lroundf(fractionalPage)
        
        wordsPageControl!.currentPage = page
        
        updateCurrentPageLabel(page)
        
    
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "secondPasswordForBackup" {
            let vc = segue.destinationViewController as! SecondPasswordViewController
            vc.delegate = self
            vc.wallet = wallet
        } else if segue.identifier == "backupVerify" {
            let vc = segue.destinationViewController as! BackupVerifyViewController
            vc.wallet = wallet
            vc.isVerifying = false
        }
    }
    
    func didGetSecondPassword(password: String) {
        wallet!.getRecoveryPhrase(password)
    }
    
    @IBAction func unwindSecondPasswordSuccess(segue: UIStoryboardSegue) {
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject: AnyObject], context: UnsafeMutablePointer<Void>) {
        let words = wallet!.recoveryPhrase.componentsSeparatedByString(" ")
        for i in 0 ..< 12 {
            wordLabels![i].text = words[i]
        }

    }
    
    deinit {
        wallet!.removeObserver(self, forKeyPath: "recoveryPhrase", context: nil)
    }
}