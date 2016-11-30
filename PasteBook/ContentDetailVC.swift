//
//  ViewController.swift
//  PasteBook
//
//  Created by Baoli Zhai on 8/31/15.
//  Copyright © 2015 Baoli Zhai. All rights reserved.
//

import UIKit


class ContentDetailVC: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    var tags = [Tag]()
    var contentTitle:String!
    var contentDetail:String!
    var itemID:Int?
    var swipeGR:UISwipeGestureRecognizer?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        let url = Bundle.main.url(forResource: "template", withExtension: "html")
        webView.delegate = self
        webView.loadRequest(URLRequest(url: url!))
        swipeGR = UISwipeGestureRecognizer(target: self, action: #selector(onSwipe))
        swipeGR?.direction = .left
        webView.addGestureRecognizer(swipeGR!)
    }
    
    func onSwipe(_ sender:UISwipeGestureRecognizer){
        if self.webView.canGoBack{
            UIView.transition(with: self.webView, duration: 0.5, options: [.transitionFlipFromRight, .allowAnimatedContent], animations: {
                self.webView.goBack()
                }, completion: nil)
        }
    }
    
    func escapeString(_ str:String)->String{
        return str.unescape()

//            .replacingOccurrences(of: "\\",with: "\\\\")
//            .replacingOccurrences(of: "\n",with: "\\n")
//            .replacingOccurrences(of: "\r",with: "\\r")
//            .replacingOccurrences(of: "\t",with: "\\t")
//            .replacingOccurrences(of: "\"",with: "\\\"")
//            .replacingOccurrences(of: "\'",with: "\\\'")
        
    }
    
    func refreshDisplay(){
        guard  contentTitle != nil else{
            return
        }
        self.title = contentTitle
        let tagsMark = self.tags.map { (item) -> String in
            "*"+item.name+"*"
            }.joined(separator: " ") + "\n\n"
        
        let jsCode = "document.getElementById('content').innerHTML=marked(\"\(escapeString(tagsMark+contentDetail))\\n\\n\")"
        webView.stringByEvaluatingJavaScript(from: "document.getElementById('content').innerHTML="+jsCode)
        webView.stringByEvaluatingJavaScript(from: "$('pre code').each(function(i, block) {hljs.highlightBlock(block);});")
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        refreshDisplay()
    }

    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "EditItem")
        {
            let vc:CreateNewItemVC = segue.destination as! CreateNewItemVC
            vc.item = (id:itemID!, title:contentTitle, content:contentDetail, tags:tags)
            vc.isNewItem = false
            vc.contentVC = self
        }
    }

}

