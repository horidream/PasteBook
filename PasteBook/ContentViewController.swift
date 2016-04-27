//
//  ViewController.swift
//  PasteBook
//
//  Created by Baoli Zhai on 8/31/15.
//  Copyright © 2015 Baoli Zhai. All rights reserved.
//

import UIKit


class ContentViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    var tags = [Tag]()
    var contentTitle:String!
    var contentDetail:String!
    var itemID:Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        let url = NSBundle.mainBundle().URLForResource("template", withExtension: "html")
        webView.delegate = self
        webView.loadRequest(NSURLRequest(URL: url!))
    }
    
    func escapeString(str:String)->String{
        return str
            .stringByReplacingOccurrencesOfString("\\",withString: "\\\\")
            .stringByReplacingOccurrencesOfString("\n",withString: "\\n")
            .stringByReplacingOccurrencesOfString("\r",withString: "\\r")
            .stringByReplacingOccurrencesOfString("\t",withString: "\\t")
            .stringByReplacingOccurrencesOfString("\"",withString: "\\\"")
            .stringByReplacingOccurrencesOfString("\'",withString: "\\\'")
        
    }
    
    func refreshDisplay(){
        guard  contentTitle != nil else{
            return
        }
        self.title = contentTitle
        let tagsMark = self.tags.map { (item) -> String in
            "*"+item.name+"*"
            }.joinWithSeparator(" ") + "\n\n"
        
        let jsCode = "document.getElementById('content').innerHTML=marked(\"\(escapeString(tagsMark+contentDetail))\\n\\n\")"
        webView.stringByEvaluatingJavaScriptFromString("document.getElementById('content').innerHTML="+jsCode)
        webView.stringByEvaluatingJavaScriptFromString("$('pre code').each(function(i, block) {hljs.highlightBlock(block);});")
        
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        refreshDisplay()
    }

    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "EditItem")
        {
            let vc:CreateNewItemVC = segue.destinationViewController as! CreateNewItemVC
            vc.item = (id:itemID!, title:contentTitle, content:contentDetail, tags:tags)
        }
    }

}

