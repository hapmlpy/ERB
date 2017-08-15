//
//  StyleAnnotationView.swift
//  streetClean
//
//  Created by JIAN LI on 8/6/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import UIKit
import Mapbox

class StyleAnnotationView: MGLAnnotationView{
    
    init(reuseIdentifier: String, size: CGFloat) {
        super.init(reuseIdentifier: reuseIdentifier)
        //大小
        frame = CGRect(x: 0, y: 0, width: size, height: size)
        
        //颜色
        backgroundColor = .darkGray
        
        //使用层的形状设计annotation的形状
        layer.cornerRadius = size/2
        layer.bounds = frame
        
        //动画
        let scaleAnimation = CABasicAnimation(keyPath: "bounds")
        let timing = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(timing)
        scaleAnimation.duration = 0.5
        scaleAnimation.fromValue = CGRect(x: 0, y: 0, width: 0, height: 0)
        scaleAnimation.toValue = layer.bounds
        layer.add(scaleAnimation, forKey: "bounds")
        CATransaction.commit()
        
        //以add模式添加到背景上
        //各种滤镜见：
        //CILuminosityBlendMode, CIOverlayBlendMode, CIScreenBlendMode, CISoftLightBlendMode,
        //CITemperatureAndTint，CIColorBlendMode

        if let compositingFilter = CIFilter(name: "CIAdditionCompositing") {
            let filter = [compositingFilter]
            layer.backgroundFilters = filter
        }

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
