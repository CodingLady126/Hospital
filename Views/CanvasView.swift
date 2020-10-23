//
//  CanvasView.swift
//  Hospital
//
//  Created by Alex on 8/3/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import Foundation
import UIKit



let π = CGFloat(Double.pi)



class CanvasView: UIImageView {
    
    // Parameters
    private let defaultLineWidth: CGFloat = 1
    
    private var drawColor: UIColor = UIColor.black
    
    private var drawingImage: UIImage?
    
    private var isEraser: Bool = false
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        print("Entity")
        
        // Draw previous image into context
        drawingImage?.draw(in: bounds)
        
        var touches = [UITouch]()
        
        // 2
        if let coalescedTouches = event?.coalescedTouches(for: touch) {
            touches = coalescedTouches
        } else {
            touches.append(touch)
        }
        
        // 3
        print("----------------------------")
        print("Touch Count:  \(touches.count)")
        print("-----------------------------")
        
        // 4
        for touch in touches {
            drawStroke(context: context, touch: touch)
        }
        
        
        drawingImage = UIGraphicsGetImageFromCurrentImageContext()
        
        if let predictedTouches = event?.predictedTouches(for: touch) {
            for touch in predictedTouches {
                drawStroke(context: context, touch: touch)
            }
        }
        
        // Update image
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    
    func setEnableEraser(bool: Bool) {
        isEraser = bool
    }
    
    
    func setDrawColor(color: UIColor) {
        self.drawColor = color
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        image = drawingImage
    }
    
    
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        image = drawingImage
    }
    
    
    
    private func drawStroke(context: CGContext?, touch: UITouch) {
        let previousLocation = touch.previousLocation(in: self)
        let location = touch.location(in: self)
        
        // Calculate line width for drawing stroke
        var lineWidth: CGFloat
        
        
//        if touch.type == .stylus {
//            if isEraser {
//                lineWidth = 6
//                context?.setBlendMode(.clear)
//            } else {
//                lineWidth = defaultLineWidth
//                context?.setBlendMode(.normal)
//            }
//        } else {
////            lineWidth = 20
//            lineWidth = defaultLineWidth
//            context?.setBlendMode(.clear)
//        }
        
        lineWidth = 1
        if isEraser {
            context?.setBlendMode(.clear)
            lineWidth = 20
        } else {
            context?.setBlendMode(.normal)
        }
        
        
        drawColor.setStroke()
        
        // Configure line
        context!.setLineWidth(lineWidth)
        context!.setLineCap(.round)
        
        // Set up the points
        context?.move(to: CGPoint(x: previousLocation.x, y: previousLocation.y))
        context?.addLine(to: CGPoint(x: location.x, y: location.y))
        
        // Draw the stroke
        context!.strokePath()
    }
    
    
    func clearCanvas(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.5, animations: {
                self.alpha = 0
            }, completion: { finished in
                self.alpha = 1
                self.image = nil
                self.drawingImage = nil
            })
        } else {
            image = nil
            drawingImage = nil
        }
    }
}
