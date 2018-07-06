//
//  UIViewExt.swift
//  CoolIosExt
//
//  Created by itzik nehemya on 06/07/2018.
//

import Foundation
import UIKit

extension UIView {
    
    var isPresented: Bool {
        get {
            return !self.isHidden
        }
        set {
            self.isHidden = !newValue
        }
    }
    
    func isScrolling () -> Bool {
        if let scrollView = self as? UIScrollView {
            if (scrollView.isDragging || scrollView.isDecelerating) {
                return true
            }
        }
        for subview in self.subviews {
            if subview.isScrolling() {
                return true
            }
        }
        return false
    }
    
    func scrollContentOffsetY() -> CGPoint {
        let offset = self.frame.origin.y - self.frame.height
        return CGPoint(x: 0, y: offset)
    }
    
    func snapshot(ofRect rect: CGRect? = nil, _ completion: (UIImage?) ->()) {
        // snapshot entire view
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: false)
        let wholeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // if no `rect` provided, return image of whole view
        
        guard let image = wholeImage, let rect = rect else { completion(wholeImage); return }
        
        // otherwise, grab specified `rect` of image
        
        let scale = image.scale
        let scaledRect = CGRect(x: rect.origin.x * scale, y: rect.origin.y * scale, width: rect.size.width * scale, height: rect.size.height * scale)
        guard let cgImage = image.cgImage?.cropping(to: scaledRect) else { return}
        let snapMmage = UIImage(cgImage: cgImage, scale: scale, orientation: .up)
        completion(snapMmage)
    }
    
    func addShadow(withColor color: UIColor) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 1
    }
    
    @discardableResult func addBorders(edges: UIRectEdge, color: UIColor = .lightGray, thickness: CGFloat = 1.0) -> [UIView] {
        
        var borders = [UIView]()
        
        func border() -> UIView {
            let border = UIView(frame: CGRect.zero)
            border.backgroundColor = color
            border.translatesAutoresizingMaskIntoConstraints = false
            return border
        }
        
        if edges.contains(.top) || edges.contains(.all) {
            let top = border()
            addSubview(top)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[top(==thickness)]",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["top": top]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[top]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["top": top]))
            borders.append(top)
        }
        
        if edges.contains(.left) || edges.contains(.all) {
            let left = border()
            addSubview(left)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[left(==thickness)]",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["left": left]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[left]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["left": left]))
            borders.append(left)
        }
        
        if edges.contains(.right) || edges.contains(.all) {
            let right = border()
            addSubview(right)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:[right(==thickness)]-(0)-|",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["right": right]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[right]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["right": right]))
            borders.append(right)
        }
        
        if edges.contains(.bottom) || edges.contains(.all) {
            let bottom = border()
            addSubview(bottom)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:[bottom(==thickness)]-(0)-|",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["bottom": bottom]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[bottom]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["bottom": bottom]))
            borders.append(bottom)
        }
        
        return borders
    }
    
    func makeRoundedCorners(_ radius: CGFloat = 5) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    public func fadeIn(duration: TimeInterval = TimeInterval(0.3)) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1
        })
    }
    public func fadeOut(duration: TimeInterval = TimeInterval(0.3)) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0
        })
    }

    // Generate image from view
    func convertToImage() -> UIImage? {
        guard bounds != CGRect.zero else {
            print("CGRect bounds is zero!! Can't export view (\(self)) to image")
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        
        if responds(to: #selector(self.drawHierarchy(in:afterScreenUpdates:))) {
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        } else {
            layer.render(in: UIGraphicsGetCurrentContext()!)
        }
        
        guard let image: UIImage = UIGraphicsGetImageFromCurrentImageContext() else { UIGraphicsEndImageContext(); return nil }
        
        UIGraphicsEndImageContext()
        
        return image
    }
}
