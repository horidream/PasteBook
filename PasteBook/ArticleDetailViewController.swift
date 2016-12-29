//
//  ArticleDetailViewController.swift
//  PasteBook
//
//  Created by Baoli Zhai on 18/12/2016.
//  Copyright © 2016 Baoli Zhai. All rights reserved.
//

import UIKit

class ArticleDetailViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    var article:Article?
    var searchText:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = Bundle.main.url(forResource: "template", withExtension: "html")!
        webView.loadRequest(URLRequest(url: url))
        webView.delegate = self
    }

    func escapeString(_ str:String)->String{
        return str
            .replacingOccurrences(of: "\\",with: "\\\\")
            .replacingOccurrences(of: "\n",with: "\\n")
            .replacingOccurrences(of: "\r",with: "\\r")
            .replacingOccurrences(of: "\t",with: "\\t")
            .replacingOccurrences(of: "\"",with: "\\\"")
            .replacingOccurrences(of: "\'",with: "\\\'")
        
    }
    
    func refreshDisplay(){
        if let article = article{
            self.title = article.title
            
            let title = "## \(article.title)\n\n"
            let tagsMark = (article.tags?.map {
                tag in
                return "*"+tag.name+"*"
                }.joined(separator: " ") ?? "")  + "\n\n"
            
            let jsCode = "document.body.style.zoom = 1.1;document.getElementById('content').innerHTML=marked(\"\(escapeString(tagsMark+article.content))\\n\\n\")"
            webView.stringByEvaluatingJavaScript(from:jsCode)
            
            var highlightCode = "$('pre code').each(function(i, block) {hljs.highlightBlock(block);});"
            if let searchText = searchText, searchText.trimmed() != ""{
                highlightCode +=  "setTimeout(function(){'\(searchText)'.split('  ').forEach(function(keyword){$('body').highlight(keyword);});}, 1000);"
            }
            webView.stringByEvaluatingJavaScript(from: highlightCode)
            
        }
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        refreshDisplay()
    }


}
