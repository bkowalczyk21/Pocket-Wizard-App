//
//  UpdateProgressAnimationView.swift
//  PocketWizard
//
//  Created by Bryce Kowalczyk on 11/17/20.
//  Copyright © 2020 Bryce Kowalczyk. All rights reserved.
//

import UIKit

class UpdateProgressAnimationView: UIView {
    
    let shapeLayer = CAShapeLayer()
    let shapeLayer2 = CAShapeLayer()
    let trackLayer = CAShapeLayer()
    
    var strokeStart: CGFloat = 0
    var strokeEnd: CGFloat = 0.125
    var stroke2Start: CGFloat = 0.5
    var stroke2End: CGFloat = 0.625
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func addLayersToView() {
        let centerPoint = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        let circularPath = UIBezierPath(arcCenter: centerPoint, radius: 120, startAngle: -(CGFloat.pi/2), endAngle: (2 * CGFloat.pi) - (CGFloat.pi / 2), clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor.systemBlue.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        shapeLayer.strokeEnd = 0
        layer.addSublayer(shapeLayer)
        
        shapeLayer2.path = circularPath.cgPath
        shapeLayer2.strokeColor = UIColor.systemBlue.cgColor
        shapeLayer2.lineWidth = 10
        shapeLayer2.fillColor = UIColor.clear.cgColor
        shapeLayer2.lineCap = .round
        shapeLayer2.strokeEnd = 0
        layer.addSublayer(shapeLayer2)
    }
    
    func setUpLayersForInstallingAnimation() {
        shapeLayer.strokeStart = strokeStart
        shapeLayer.strokeEnd = strokeEnd
        shapeLayer2.strokeStart = stroke2Start
        shapeLayer2.strokeEnd = stroke2End
    }
    
    func installingAnimationTick() {
        strokeEnd += 0.125
        strokeStart += 0.125
        stroke2Start += 0.125
        stroke2End += 0.125
        if strokeStart == 1 && strokeEnd == 1.125 {
            strokeStart = 0
            strokeEnd = 0.125
        } else if stroke2Start == 1 && stroke2End == 1.125 {
            stroke2Start = 0
            stroke2End = 0.125
        }
        shapeLayer.strokeStart = strokeStart
        shapeLayer.strokeEnd = strokeEnd
        shapeLayer2.strokeStart = stroke2Start
        shapeLayer2.strokeEnd = stroke2End
    }
    
    func removeLayers() {
        shapeLayer.isHidden = true
        shapeLayer2.isHidden = true
        trackLayer.isHidden = true
        layer.removeAllAnimations()
    }
}
