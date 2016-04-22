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
    var tags = [String]()
    var contentTitle:String!
    var contentDetail:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        let url = NSBundle.mainBundle().URLForResource("test", withExtension: "html")
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
    func webViewDidFinishLoad(webView: UIWebView) {
        guard  contentTitle != nil else{
            return
        }
        self.title = contentTitle
        let tagsMark = self.tags.map { (item) -> String in
            "*"+item+"*"
        }.joinWithSeparator(" ") + "\n\n"
        
        let jsCode = "document.getElementById('content').innerHTML=marked(\"\(escapeString(tagsMark+contentDetail))\\n\\n\")"
        webView.stringByEvaluatingJavaScriptFromString("document.getElementById('content').innerHTML="+jsCode)
        webView.stringByEvaluatingJavaScriptFromString("$('pre code').each(function(i, block) {hljs.highlightBlock(block);});")
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

