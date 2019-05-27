//
//  ProgressBar.swift
//  project-manager-app
//
//  Created by Saiyaff Farouk on 5/26/19.
//  Copyright © 2019 Saiyaff Farouk. All rights reserved.
//

import UIKit

class ProgressBar: UIView {
    
    @IBInspectable public var backgroundCircleColor: UIColor = UIColor.lightGray
    @IBInspectable public var startGradientColor: UIColor = UIColor.red
    @IBInspectable public var endGradientColor: UIColor = UIColor.green
    @IBInspectable public var textColor: UIColor = UIColor.black
    
    private var backgroundLayer: CAShapeLayer!
    private var foregroundLayer: CAShapeLayer!
    private var textLayer: CATextLayer!
    private var gradientLayer: CAGradientLayer!
    
    public var progress: CGFloat = 0 {
        didSet {
            didProgressUpdated()
        }
    }

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        guard layer.sublayers == nil else {
            return
        }
        
        // Drawing code
        let width = rect.width
        let height = rect.height
        
        let lineWidth = 0.1 * min(width, height)

        backgroundLayer = createCircleLayer(rect: rect, fillColor: UIColor.clear.cgColor, strokeColor: UIColor.lightGray.cgColor, lineWidth: lineWidth)
         
        foregroundLayer = createCircleLayer(rect: rect, fillColor: UIColor.clear.cgColor, strokeColor: UIColor.red.cgColor, lineWidth: lineWidth)
        
        gradientLayer = CAGradientLayer()
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.colors = [startGradientColor.cgColor, endGradientColor.cgColor]
        gradientLayer.frame = rect
        gradientLayer.mask = foregroundLayer
        
        textLayer = createTextLayer(rect: rect, textColor: UIColor.black.cgColor)
        
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(gradientLayer)
        layer.addSublayer(textLayer)
    }
    
    func createCircleLayer(rect: CGRect, fillColor: CGColor, strokeColor: CGColor, lineWidth: CGFloat) -> CAShapeLayer {
        
        let width = rect.width
        let height = rect.height
        
//        let lineWidth = 0.1 * min(width, height)
        
        let center = CGPoint(x: width/2, y: height/2)
        let radius = (min(width, height) - lineWidth) / 2
        
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi
        
        let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        let circleLayer = CAShapeLayer()
        
        circleLayer.path = circularPath.cgPath
        
        circleLayer.fillColor = fillColor
        circleLayer.strokeColor = strokeColor
        circleLayer.lineWidth = lineWidth
        circleLayer.lineCap = .round
        
        return circleLayer
    }
    
    func createTextLayer(rect: CGRect, textColor: CGColor) -> CATextLayer {
        let width = rect.width
        let height = rect.height
        
        let fontSize = min(width, height) / 4
        let offset = min(width, height) * 0.1
        
        let textLayer = CATextLayer()
        
        textLayer.string = "\(Int(progress * 100))"
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.foregroundColor = textColor
        textLayer.fontSize = fontSize
        
        textLayer.frame = CGRect(x: 0, y: (height - fontSize - offset) / 2, width: width, height: fontSize + offset)
        
        textLayer.alignmentMode = .center
        
        return textLayer
    }
    
    func didProgressUpdated() {
         textLayer?.string = "\(Int(progress * 100))%"
        foregroundLayer? .strokeEnd = progress
    }


}
