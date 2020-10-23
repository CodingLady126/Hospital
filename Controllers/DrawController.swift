//
//  DrawController.swift
//  Hospital
//
//  Created by Alex on 8/4/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import UIKit


protocol DrawDelegate {
    func doneButtonTapped(_ sender: Any)
}


class DrawController: UIViewController {
    
    @IBOutlet weak var tButton: TButton!
    @IBOutlet weak var blackButton: BlackButton!
    @IBOutlet weak var redButton: RedButton!
    @IBOutlet weak var eraserButton: EraserButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textView: PrettyTextView!
    @IBOutlet weak var canvasView: CanvasView!
    
    
    var which_part: String?
    var delegate: DrawDelegate!
    var data_dic = Dictionary<String, Any>()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setLayout()
        
        textView.text = "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
        blackButton.isSelected = true
    }
    
    
    func setLayout() {
        view.bounds.size.height = UIScreen.main.bounds.size.height * 0.65
        view.bounds.size.width = UIScreen.main.bounds.size.width * 0.8
    }
    
    func resetButtonSeletion() {
        tButton.isSelected = false
        blackButton.isSelected = false
        redButton.isSelected = false
        eraserButton.isSelected = false
    }
    

    @IBAction func tBtnTapped(_ sender: Any) {
        resetButtonSeletion()
        tButton.isSelected = true
        containerView.bringSubviewToFront(textView)
        textView.becomeFirstResponder()
    }
    
    @IBAction func blackBtnTapped(_ sender: Any) {
        resetButtonSeletion()
        blackButton.isSelected = true
        textView.resignFirstResponder()
        containerView.bringSubviewToFront(canvasView)
        canvasView.setDrawColor(color: UIColor.black)
        canvasView.setEnableEraser(bool: false)
    }
    
    @IBAction func redBtnTapped(_ sender: Any) {
        resetButtonSeletion()
        redButton.isSelected = true
        textView.resignFirstResponder()
        containerView.bringSubviewToFront(canvasView)
        canvasView.setDrawColor(color: UIColor.red)
        canvasView.setEnableEraser(bool: false)
    }
    
    @IBAction func eraserBtnTapped(_ sender: Any) {
        resetButtonSeletion()
        eraserButton.isSelected = true
        textView.resignFirstResponder()
        containerView.bringSubviewToFront(canvasView)
        canvasView.setEnableEraser(bool: true)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        let can_img = canvasView.image
        let text : String = textView.text
        data_dic = ["key": self.which_part!, "image": can_img as Any, "text": text]
        
        delegate.doneButtonTapped(data_dic)
    }
    
    // Shake to clear screen
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        canvasView.clearCanvas(animated: true)
    }
}
