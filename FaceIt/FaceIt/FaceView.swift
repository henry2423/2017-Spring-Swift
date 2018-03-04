//
//  FaceView.swift
//  FaceIt
//
//  Created by Henry on 30/06/2017.
//  Copyright © 2017 henry. All rights reserved.
//

import UIKit

@IBDesignable
class FaceView: UIView {
    
    @IBInspectable  //always assign type to IBInspectable, it can't auto infer
    var scale: CGFloat = 0.9 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var eyesOpen: Bool = true { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var mouthCurvature: Double = 1.0 { didSet { setNeedsDisplay() } } // 1.0 is full smile and -1.0 is full frown
    
    @IBInspectable
    var lineWidth: CGFloat = 5.0 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var color: UIColor = UIColor.blue { didSet { setNeedsDisplay() } }
    
    func changeScale(byReactingto pinchRecognizer: UIPinchGestureRecognizer)
    {
        switch pinchRecognizer.state
        {
            case .changed, .ended:
                scale *= pinchRecognizer.scale
                pinchRecognizer.scale = 1
            default:
                break
        }
    }
    
    
    private var skullRaduis: CGFloat {
        return min(bounds.size.width, bounds.size.height) / 2 * scale
    }
    
    private var skullCenter: CGPoint {
        get {
            return CGPoint(x: bounds.midX, y: bounds.midY) //convert(center, from: superview)
        }
    }
    
    private enum Eye {
        case left
        case right
    }
    
    private func pathForEye(_ eye: Eye) -> UIBezierPath {
        func centerOfEye(_ eye: Eye) -> CGPoint {
            let eyeOffset = skullRaduis / Ratios.skullRaduisToEyeOffset
            var eyeCenter = skullCenter
            eyeCenter.y -= eyeOffset
            eyeCenter.x += ((eye == .left) ? -1 : 1) * eyeOffset
            return eyeCenter
        }
        
        let eyeRaduis = skullRaduis / Ratios.skullRaduisToEyeRaduis
        let eyeCenter = centerOfEye(eye)
        
        let path: UIBezierPath
        if eyesOpen
        {
            path = UIBezierPath(arcCenter: eyeCenter, radius: eyeRaduis, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        }
        else
        {
            path = UIBezierPath()
            path.move(to: CGPoint(x: eyeCenter.x - eyeRaduis, y: eyeCenter.y))
            path.addLine(to: CGPoint(x: eyeCenter.x + eyeRaduis, y: eyeCenter.y))
        }
        
        path.lineWidth = lineWidth
        return path
            
    }
    
    private func pathForMouth() -> UIBezierPath {
        let mouthWidth = skullRaduis / Ratios.skullRaduisToMouthWidth
        let mouthHeight = skullRaduis / Ratios.skullRaduisToMouthHeight
        let mouthOffset = skullRaduis / Ratios.skullRaduisToMouthOffset
        
        let mouthRect = CGRect(
            x: skullCenter.x - mouthWidth / 2,
            y: skullCenter.y + mouthOffset,
            width: mouthWidth,
            height: mouthHeight
        )
        let smileOffset = CGFloat(max(-1, min(mouthCurvature, 1))) * mouthRect.height
        
        let start = CGPoint(x: mouthRect.minX, y: mouthRect.midY)
        let end = CGPoint(x: mouthRect.maxX, y: mouthRect.midY)
        
        let cp1 = CGPoint(x: start.x + mouthRect.width / 3, y: start.y + smileOffset)
        let cp2 = CGPoint(x: end.x - mouthRect.width / 3, y: start.y + smileOffset)
        
        let path = UIBezierPath()
        path.move(to: start)
        path.addCurve(to: end, controlPoint1: cp1, controlPoint2: cp2)
        path.lineWidth = lineWidth
        return path
        
    }
    
    private func pathForSkull() -> UIBezierPath {
        let path = UIBezierPath(arcCenter: skullCenter, radius: skullRaduis, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: false)
        path.lineWidth = lineWidth
        return path
    }
    
    override func draw(_ rect: CGRect) {
        color.set()
        pathForSkull().stroke()
        pathForEye(Eye.left).stroke()
        pathForEye(.right).stroke()
        pathForMouth().stroke()
    }
    
    private struct Ratios {
        static let skullRaduisToEyeOffset: CGFloat = 3
        static let skullRaduisToEyeRaduis: CGFloat = 10
        static let skullRaduisToMouthWidth: CGFloat = 1
        static let skullRaduisToMouthHeight: CGFloat = 3
        static let skullRaduisToMouthOffset: CGFloat = 3
    }
    
}
