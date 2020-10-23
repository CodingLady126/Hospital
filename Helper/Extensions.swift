//
//  Extensions.swift
//  Hospital
//
//  Created by Alex on 7/30/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import Foundation
import UIKit
import Material






class EraserButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setButton()
    }
    
    func setButton() {
        self.setImage(UIImage(named: "icons8-erase-active")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
        self.setImage(UIImage(named: "icons8-erase-active")?.withRenderingMode(.alwaysOriginal), for: .selected)
    }
}


class RedButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setButton()
    }
    
    func setButton() {
        self.setImage(UIImage(named: "icons8-crayon-red-active")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
        self.setImage(UIImage(named: "icons8-crayon-red-active")?.withRenderingMode(.alwaysOriginal), for: .selected)
    }
}


class BlackButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setButton()
    }
    
    func setButton() {
        self.setImage(UIImage(named: "icons8-crayon-black-active")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
        self.setImage(UIImage(named: "icons8-crayon-black-active")?.withRenderingMode(.alwaysOriginal), for: .selected)
    }
}


class TButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setButton()
    }
    
    func setButton() {
        self.setImage(UIImage(named: "icons8-text-active")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
        self.setImage(UIImage(named: "icons8-text-active")?.withRenderingMode(.alwaysOriginal), for: .selected)
    }
}


class RoundLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setRound()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setRound()
    }
    
    func setRound() {
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }
}



class PrettySearchbar: UISearchBar {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        searchBarStyle = UISearchBar.Style.minimal
        
        let textField = value(forKey: "_searchField") as! UITextField
        textField.backgroundColor = UIColor.white
        textField.autocapitalizationType = .none
    }
}


class CornerView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setCorner()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setCorner()
    }
    
    func setCorner() {
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor(red: 221/255, green: 237/255, blue: 247/255, alpha: 1)
    }
}


class RoundButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setBorder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setBorder()
    }
    
    func setBorder() {
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }
}



class PrettyTextView: UITextView {
    
    @IBInspectable var multiLineWithDoneButton: Bool = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setBorder()
    }
    
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if multiLineWithDoneButton { // Add a toolbar with a done button to the keyboard, if required
            returnKeyType = UIReturnKeyType.default
            let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: Int(self.frame.size.width), height: 45))
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(doneButtonPressed))
            toolbar.setItems([flexibleSpace, doneButton], animated: false)
            toolbar.sizeToFit()
            inputAccessoryView = toolbar
        } else {
            returnKeyType = UIReturnKeyType.done
        }
    }
    
    @objc private func doneButtonPressed() {
        endEditing(true)
    }
    
    func setBorder() {
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }
}




extension ErrorTextField {
    func setLeftView(img_name: String) {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: img_name)
        self.leftView = imageView
        self.placeholderActiveColor = UIColor(red: 230/255, green: 82/255, blue: 44/255, alpha: 1)
        self.placeholderNormalColor = UIColor(red: 52/255, green: 106/255, blue: 219/255, alpha: 1)
        self.dividerNormalColor = UIColor(red: 52/255, green: 106/255, blue: 219/255, alpha: 1)
        self.errorVerticalOffset = 0
    }
}
