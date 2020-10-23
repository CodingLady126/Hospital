//
//  PDFPreviewController.swift
//  Hospital
//
//  Created by Alex on 8/3/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import UIKit
import WebKit



class PDFPreviewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setLayout()
        load()
    }
    
    func load() {
        webView.loadFileURL(url!, allowingReadAccessTo: url!)
    }
    
    func setLayout() {
        view.bounds.size.height = UIScreen.main.bounds.size.height * 0.8
        view.bounds.size.width = UIScreen.main.bounds.size.width * 0.8
    }
}
