//
//  KFCountDownView.swift
//  KFCountDownProject
//
//  Created by zhkf on 2017/12/22.
//  Copyright © 2017年 KF. All rights reserved.
//

import UIKit

class KFCountDownView: UIView {
    
    public var totalTime: Int = 15
    
    /// interval should be equal or greater than 0.001
    public var animationInterval: Float = 0.05
    public var lineWidth: CGFloat = 4
    public var closeButtonImage: UIImage? = nil {
        didSet {
            closedButton?.setBackgroundImage(closeButtonImage, for: .normal)
        }
    }
    public var closeButtonBackgroundColor: UIColor = UIColor.gray {
        didSet {
            closedButton?.backgroundColor = closeButtonBackgroundColor
        }
    }
    
    public var countDownCircleColor = UIColor.init(red: 102/255.0, green: 1, blue: 1, alpha: 1) {
        didSet {
            countDownEmitterColor = countDownCircleColor
        }
    }
    public var countDownEmitterColor: UIColor {
        didSet {
            eCell?.contents = getImageWithColor(color: countDownEmitterColor, size: CGSize (width: 1, height: 1))?.cgImage
        }
    }
    
    private var closedButton: UIButton?
    private var eLayer: CAEmitterLayer?
    private var eCell: CAEmitterCell?
    private var shaperLayer: CAShapeLayer?
    private var gcdTimer: DispatchSourceTimer?
    private var count = 0
    private var currentProgress: Float = 0
    
    override init(frame: CGRect) {
        self.countDownEmitterColor = self.countDownCircleColor
        super.init(frame: frame)
        initializeView()
    }
    
    convenience init() {
        fatalError("not supported")
    }
    
    private func initializeView() {
        self.backgroundColor = UIColor.clear
        
        let width = self.frame.width - lineWidth
        let closedButton = UIButton.init(type: .custom)
        closedButton.backgroundColor  = closeButtonBackgroundColor;
        closedButton.layer.cornerRadius = width / 2
        closedButton.layer.masksToBounds = true
        closedButton.frame = CGRect (x: 0, y: 0, width: width, height: width)
        closedButton.center = CGPoint (x: self.frame.width/2, y: self.frame.height/2)
        self.addSubview(closedButton)
        
        closedButton .addTarget(self, action: #selector(closedButtonClick), for: .touchUpInside)
        self.closedButton = closedButton
        
        let layer = CAEmitterLayer.init()
        layer.frame = CGRect (x: 0, y: 0, width: width, height: width)
        layer.emitterSize = CGSize (width: lineWidth, height: lineWidth)
        layer.emitterShape = kCAEmitterLayerCircle
        layer.emitterMode = kCAEmitterLayerSurface
        layer.renderMode = kCAEmitterLayerAdditive
        
        eLayer = layer
        
        let cell = CAEmitterCell.init()
        cell.name = "countDown"
        cell.color = countDownEmitterColor.cgColor
        cell.contents = getImageWithColor(color: countDownEmitterColor, size: CGSize (width: 1, height: 1))?.cgImage
        cell.birthRate = 200
        cell.lifetime = 0.3
        
        eLayer?.emitterCells = [cell]
        eCell = cell
        
        self.layer .addSublayer(layer)
        
        let shapeLayer = CAShapeLayer.init()
        
        shapeLayer.path = getCirclePath(progress: 0).0.cgPath
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineWidth = lineWidth
        shapeLayer.strokeColor = countDownCircleColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        self.layer .addSublayer(shapeLayer)
        
        self.shaperLayer = shapeLayer
        
        startAnimation()
    }
    
    @objc func closedButtonClick() {
        endAnimation()
    }
    
    private func startAnimation() {
        self.isHidden = false
        count = 0
        currentProgress = 0
        if gcdTimer == nil {
           createTimer()
        }
        gcdTimer?.resume()
    }
    
    private func createTimer() {
        gcdTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        let timeInterval = DispatchTimeInterval.milliseconds(Int(animationInterval * 1000))
        let leewayInterval = DispatchTimeInterval.milliseconds(Int(animationInterval * 500))
        
        gcdTimer?.schedule(deadline: .now() + timeInterval, repeating: timeInterval, leeway: leewayInterval)
        gcdTimer?.setEventHandler(handler: { [weak self] in
            self? .timeRun()
        })
    }
    
    private func timeRun() {
        count = count + 1
        currentProgress = Float(count) * animationInterval/Float(totalTime)
        if currentProgress > 1 {
            closedButtonClick()
            return
        }
        let tuple = getCirclePath(progress: currentProgress)
        shaperLayer?.path = tuple.0.cgPath
        eLayer?.emitterPosition = tuple.1
    }
    
    private func endAnimation() {
        gcdTimer?.suspend()
        count = 0
        currentProgress = 0
        
        self.isHidden = true
    }
    
    private func getCirclePath(progress: Float) -> (UIBezierPath, CGPoint) {
        let path = UIBezierPath.init()
        let passAngle = progress * Float.pi * 2
        let arcCenter = CGPoint (x: self.center.x - self.frame.minX, y: self.center.y - self.frame.minY)
        let radius = self.frame.width/2 - lineWidth/2
        path.addArc(withCenter: arcCenter, radius: radius, startAngle: CGFloat(-Float.pi/2 + passAngle), endAngle: CGFloat(Float.pi * 1.5), clockwise: true)
        
        let currentPointX: CGFloat = arcCenter.x + CGFloat(cosf(-Float.pi/2 + passAngle)) * radius
        let currentPointY: CGFloat = arcCenter.y + CGFloat(sinf(-Float.pi/2 + passAngle)) * radius
        return (path, CGPoint (x: currentPointX, y: currentPointY))
    }
    
    private func getImageWithColor(color: UIColor, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        
        let rect = CGRect (x: 0, y: 0, width: size.width, height: size.height)
        let bezierPath = UIBezierPath.init(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize (width: size.width/2, height: size.height/2))
        context?.addPath(bezierPath.cgPath)
        context?.setFillColor(color.cgColor)
        context?.setStrokeColor(color.cgColor)
        context?.fillPath()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.countDownEmitterColor = self.countDownCircleColor
        super.init(coder: aDecoder)
        initializeView()
    }
    
    deinit {
        gcdTimer?.cancel()
        gcdTimer = nil
    }
}
