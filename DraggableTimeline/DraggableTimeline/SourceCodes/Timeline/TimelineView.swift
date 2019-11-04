//
//  TimelineView.swift
//  DraggableTimeline
//
//  Created by caowanping on 2019/11/2.
//  Copyright © 2019 industriousguy. All rights reserved.
//

import Cocoa

enum TimelineDisplayType {
    case left
    case right
    case both
}

private typealias SectionItem = (point: CGPoint, bubbleRect: CGRect, descriptionRect: CGRect?, titleLabel: NSTextField, descriptionLabel: NSTextField?, pointColor: CGColor, lineColor: CGColor, fill: Bool, onRight: Bool)

class TimelineView: NSScrollView {
    
    private static let gap: CGFloat = 15.0
    
    private var sections: [SectionItem] = []
    
    var bubbleColor: NSColor = .init(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0) {
        didSet {
            DispatchQueue.main.async {
                self.refresh()
            }
        }
    }
    var titleColor: NSColor = .white {
        didSet {
            DispatchQueue.main.async {
                self.refresh()
            }
        }
    }
    var descriptionColor: NSColor = .gray {
        didSet {
            DispatchQueue.main.async {
                self.refresh()
            }
        }
    }
    var hasBubbleArrow: Bool = true {
        didSet {
            DispatchQueue.main.async {
                self.refresh()
            }
        }
    }
    
    var bubbleArraySize: NSSize = .init(width: 8, height: 16) {
        didSet {
            if bubbleArraySize.width < 0.0 {
                bubbleArraySize.width = 0.0
            }else if bubbleArraySize.width > 10.0 {
                bubbleArraySize.width = 10.0
            }
            if bubbleArraySize.height < 0.0 {
                bubbleArraySize.height = 0.0
            }else if bubbleArraySize.height > 10.0 {
                bubbleArraySize.height = 10.0
            }
            DispatchQueue.main.async {
                self.refresh()
            }
        }
    }
    
    var pointDiameter: CGFloat = 6.0 {
        didSet {
            if pointDiameter < 0.0 {
                pointDiameter = 0.0
            }else if pointDiameter > 100.0 {
                pointDiameter = 100.0
            }
            DispatchQueue.main.async {
                self.refresh()
            }
        }
    }
    
    var displayType: TimelineDisplayType = .both {
        didSet {
            DispatchQueue.main.async {
                self.refresh()
            }
        }
    }
    
    var lineWidth: CGFloat = 2.0 {
        didSet {
            if lineWidth < 0.0 {
                lineWidth = 0.0
            }else if lineWidth > 20.0 {
                lineWidth = 20.0
            }
            DispatchQueue.main.async {
                self.refresh()
            }
        }
    }
    
    var bubbleRadius: CGFloat = 4.0 {
        didSet {
            if bubbleRadius < 0.0 {
                bubbleRadius = 0.0
            }else if bubbleRadius > 6.0 {
                bubbleRadius = 6.0
            }
            DispatchQueue.main.async {
                self.refresh()
            }
        }
    }
    
    var points:[TimelinePoint] = [] {
        didSet {
            DispatchQueue.main.async {
                self.refresh()
            }
        }
    }
    
    override func layout() {
        super.layout()
    }
    
    required override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func refresh() {
        self.documentView?.layer?.sublayers?.forEach({ (layer) in
            if layer.isKind(of: CAShapeLayer.self) {
                layer.removeFromSuperlayer()
            }
        })
        self.documentView?.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        self.sections.removeAll()
        self.buildSections()
        
        self.layer?.setNeedsDisplay()
        self.layer?.displayIfNeeded()
    }
    
    private func calcWidth() -> CGFloat {
        let width = self.bounds.width - (self.contentInsets.left + self.contentInsets.right) - self.pointDiameter - self.lineWidth - TimelineView.gap * 2
        return self.displayType == .both ? width / 2 : width
    }
    
    private func timelinePointX() -> CGFloat {
        switch self.displayType {
        case .left:
            return NSMaxX(self.documentView!.bounds) - self.contentInsets.right - self.lineWidth / 2
        case .right:
            return NSMinX(self.documentView!.bounds) + self.contentInsets.left + self.lineWidth / 2
        case .both:
            return (NSWidth(self.documentView!.bounds) - self.contentInsets.left - self.contentInsets.right) / 2.0 - self.lineWidth / 2
        }
    }
    
    private func isOnRightSide(_ index: Int) -> Bool {
        if self.displayType == .both {
            return index % 2 == 0
        }else {
            return self.displayType == .right ? true : false
        }
    }
    
    private func buildSections() {
        
        if self.documentView!.isFlipped == false {
            self.buildSectionsInNonFlippedCoordinateSystemView()
        }else {
            self.buildSectionsInFlippedCoordinateSystemView()
        }
        
        self.setNeedsDisplay(self.bounds)
    }
    
    private func buildSectionsInNonFlippedCoordinateSystemView() {
        guard self.documentView != nil else {
            fatalError("The document view should not be nil")
        }
        
        var newBoundHeight: CGFloat = 0.0
        let pointX = self.timelinePointX()
        var y: CGFloat = self.documentView!.bounds.origin.y + self.contentInsets.bottom
        let maxWidth = self.calcWidth()
        let itemInterval = TimelineView.gap * 2.5
        let labelInterval: CGFloat = 3.0
        for i in (0..<self.points.count).reversed() {
            let item = self.points[i]
            let titleLabel = self.buildTitleLabel(i)
            let descriptionLabel = self.buildDescriptionLabel(i)
            
            let titleHeight = titleLabel.intrinsicContentSize.height
            let bubbleHeight = titleHeight + TimelineView.gap
            let descriptionHeight = descriptionLabel?.intrinsicContentSize.height ?? 0
            let height: CGFloat = titleHeight + descriptionHeight
            
            let maxTitleWidth = maxWidth
            var titleWidth = titleLabel.intrinsicContentSize.width + 20
            if titleWidth > maxTitleWidth {
                titleWidth = maxTitleWidth
            }
            
            let offset: CGFloat = self.hasBubbleArrow ? 13 : 5
            let onRight: Bool = self.isOnRightSide(i)
            
            let bubblePointX = onRight ? pointX + self.pointDiameter + offset : pointX - titleWidth - offset - self.pointDiameter
            
            let bubbleRect = CGRect(
                x: bubblePointX,
                y: y + descriptionHeight + labelInterval,
                width: titleWidth,
                height: bubbleHeight)
            
            let desPointX = onRight ? bubbleRect.origin.x : pointX - maxWidth - offset - self.pointDiameter
            var descriptionRect: CGRect?
            if descriptionHeight > 0 {
                descriptionRect = CGRect(
                    x: desPointX,
                    y: y,
                    width: maxWidth,
                    height: descriptionHeight)
            }
            
            let point = CGPoint(x: pointX, y: bubbleRect.origin.y + bubbleHeight / 2 - self.pointDiameter / 2)
            
            descriptionLabel?.alignment = onRight ? .left : .right
            self.sections.append((point, bubbleRect, descriptionRect, titleLabel, descriptionLabel, item.pointColor.cgColor, item.lineColor.cgColor, item.fill, onRight: onRight))
            
            y += height
            y += itemInterval
            newBoundHeight += height
            newBoundHeight += itemInterval
        }
        
        newBoundHeight += self.pointDiameter / 2
        let newContentSize = CGSize(width: self.documentView!.bounds.width - (self.contentInsets.left + self.contentInsets.right), height: newBoundHeight)
        self.documentView!.setFrameSize(newContentSize)
    }
    
    private func buildSectionsInFlippedCoordinateSystemView() {

        guard self.documentView != nil else {
            fatalError("The document view should not be nil")
        }
        
        var y: CGFloat = self.documentView!.bounds.origin.y + self.contentInsets.top
        let maxWidth = self.calcWidth()
        let itemInterval = TimelineView.gap * 2.5
        let labelInterval: CGFloat = 3.0
        for i in 0 ..< self.points.count {
            let item = self.points[i]
            let titleLabel = self.buildTitleLabel(i)
            let descriptionLabel = self.buildDescriptionLabel(i)
            let titleHeight = titleLabel.intrinsicContentSize.height
            let bubbleHeight = titleHeight + TimelineView.gap
            let descriptionHeight = descriptionLabel?.intrinsicContentSize.height ?? 0
            let height: CGFloat = titleHeight + descriptionHeight
         
            let point = CGPoint(x: self.documentView!.bounds.origin.x + self.contentInsets.left + self.lineWidth / 2, y: y + bubbleHeight / 2)
             
            let maxTitleWidth = maxWidth
            var titleWidth = titleLabel.intrinsicContentSize.width + 20
            if titleWidth > maxTitleWidth {
                titleWidth = maxTitleWidth
            }
             
            let offset: CGFloat = self.hasBubbleArrow ? 13 : 5
            let bubbleRect = CGRect(
                x: point.x + self.pointDiameter + self.lineWidth / 2 + offset,
                y: y + self.pointDiameter / 2,
                width: titleWidth,
                height: bubbleHeight)
             
            var descriptionRect: CGRect?
            if descriptionHeight > 0 {
                descriptionRect = CGRect(
                    x: bubbleRect.origin.x,
                    y: bubbleRect.origin.y + bubbleRect.height + labelInterval,
                    width: maxWidth,
                    height: descriptionHeight)
             }
            
            self.sections.append((point, bubbleRect, descriptionRect, titleLabel, descriptionLabel, item.pointColor.cgColor, item.lineColor.cgColor, item.fill, onRight: self.isOnRightSide(i)))
             
            y += height
            y += itemInterval

        }
         
        y += self.pointDiameter / 2
        let newContentSize = CGSize(width: self.documentView!.bounds.width - (self.contentInsets.left + self.contentInsets.right), height: y)
        self.documentView!.setFrameSize(newContentSize)
    }
    
    private func buildTitleLabel(_ index: Int) -> NSTextField {
        let label = NSTextField.init()
        label.stringValue = points[index].title
        label.font = .systemFont(ofSize: 12.0)
        label.isBordered = false
        label.isEditable = false
        label.isSelectable = true
        label.focusRingType = .none
        label.backgroundColor = .clear
        label.lineBreakMode = .byWordWrapping
        label.preferredMaxLayoutWidth = self.calcWidth()
        return label
    }
    
    private func buildDescriptionLabel(_ index: Int) -> NSTextField? {
        if let text = self.points[index].description {
            let label = NSTextField.init()
            label.stringValue = text
            label.font = .systemFont(ofSize: 10.0)
            label.isBordered = false
            label.isEditable = false
            label.isSelectable = true
            label.focusRingType = .none
            label.backgroundColor = .clear
            label.lineBreakMode = .byWordWrapping
            label.preferredMaxLayoutWidth = calcWidth()
            return label
        }else {
            return nil
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        self.saveGState { (cgContext) in
            
            for i in 0 ..< self.sections.count {
                let item = self.sections[i]
                if (i < self.sections.count - 1) {
                    var start = item.point
                    start.x += self.pointDiameter / 2
                    start.y += self.pointDiameter
                    
                    var end = self.sections[i + 1].point
                    end.x = start.x
                    
                    self.drawLine(start, end: end, color: self.sections[i].lineColor)
                }
                
                self.drawPoint(item.point, color: item.pointColor, fill: item.fill)
                self.drawBubble(item.bubbleRect, backgroundColor: self.bubbleColor, textColor: self.titleColor, titleLabel: item.titleLabel, onRight: item.onRight)
                
                if let descriptionLabel = item.descriptionLabel,
                    let descriptionRect = item.descriptionRect {
                    self.drawDescription(descriptionRect, textColor: self.descriptionColor, descriptionLabel: descriptionLabel)
                }
                
            }
        }
        
    }
    
    func drawLine(_ start: CGPoint, end: CGPoint, color: CGColor) {
        let path = CGMutablePath.init()
        path.move(to: start)
        path.addLine(to: end)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = self.lineWidth
        
        self.documentView?.layer?.addSublayer(shapeLayer)
    }
    
    private func drawPoint(_ point: CGPoint, color: CGColor, fill: Bool) {
        let path = CGPath.init(ellipseIn: CGRect(x: point.x, y: point.y, width: self.pointDiameter, height: self.pointDiameter), transform: nil)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path
        shapeLayer.strokeColor = color
        shapeLayer.fillColor = fill ? color : .clear
        shapeLayer.lineWidth = self.lineWidth
        
        self.documentView?.layer?.addSublayer(shapeLayer)
    }
    
    private func drawBubble(_ rect: CGRect, backgroundColor: NSColor, textColor: NSColor, titleLabel: NSTextField, onRight: Bool) {
        let path = CGMutablePath.init()
        path.addRoundedRect(in: rect, cornerWidth: self.bubbleRadius, cornerHeight: self.bubbleRadius)
    
        if self.hasBubbleArrow && self.bubbleArraySize != .zero {
            let pointX = onRight ? NSMinX(rect) : NSMaxX(rect)
            let arrowPointX = onRight ? pointX - self.bubbleArraySize.width : pointX + self.bubbleArraySize.width
            let startPont = CGPoint(x: pointX , y: rect.origin.y + (rect.height - self.bubbleArraySize.height) / 2.0 )
            path.move(to: startPont)
            path.addLine(to: CGPoint(x: arrowPointX, y: rect.origin.y + rect.height / 2))
            path.addLine(to: CGPoint(x: pointX, y: rect.origin.y + (rect.height + self.bubbleArraySize.height) / 2))
        }
       
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path
        shapeLayer.fillColor = backgroundColor.cgColor
        
        self.documentView?.layer?.addSublayer(shapeLayer)
        
        let titleLabelHeight: CGFloat = 15.0
        let titleRect = CGRect(x: rect.origin.x + 10, y: rect.origin.y + (rect.size.height - titleLabelHeight) / 2  , width: rect.size.width - 10, height: titleLabelHeight)
        titleLabel.textColor = textColor
        titleLabel.frame = titleRect
        self.documentView?.addSubview(titleLabel)
        
    }
    
    private func drawDescription(_ rect: CGRect, textColor: NSColor, descriptionLabel: NSTextField) {
        descriptionLabel.textColor = textColor
        descriptionLabel.frame = CGRect(x: rect.origin.x + 7, y: rect.origin.y, width: rect.width - 10, height: rect.height)
        self.documentView?.addSubview(descriptionLabel)
    }
}

extension TimelineView {
    private var currentContext : CGContext? {
        get {
            if #available(OSX 10.10, *) {
                return NSGraphicsContext.current?.cgContext
            } else if let contextPointer = NSGraphicsContext.current?.graphicsPort {
                let context: CGContext = Unmanaged.fromOpaque(contextPointer).takeUnretainedValue()
                return context
            }
            return nil
        }
    }

    private func saveGState(drawStuff: (CGContext) -> ()) -> () {
        if let context = self.currentContext {
            context.saveGState ()
            drawStuff(context)
            context.restoreGState ()
        }
    }

}

