//
//  TimelineView.swift
//  DraggableTimeline
//
//  Created by caowanping on 2019/11/2.
//  Copyright © 2019 industriousguy. All rights reserved.
//

import Cocoa

private typealias SectionItem = (point: CGPoint, bubbleRect: CGRect, descriptionRect: CGRect?, titleLabel: NSTextField, descriptionLabel: NSTextField?, pointColor: CGColor, lineColor: CGColor, fill: Bool)

class TimelineView: NSScrollView {
    
    private static let gap: CGFloat = 15.0
    
    var pointDiameter: CGFloat = 6.0 {
        didSet {
            if pointDiameter < 0.0 {
                pointDiameter = 0.0
            }else if pointDiameter > 100.0 {
                pointDiameter = 100.0
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
        }
    }
    
    var bubbleRadius: CGFloat = 2.0 {
        didSet {
            if bubbleRadius < 0.0 {
                bubbleRadius = 0.0
            }else if bubbleRadius > 6.0 {
                bubbleRadius = 6.0
            }
        }
    }
    
    var bubbleColor: NSColor = .init(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
    var titleColor: NSColor = .white
    var descriptionColor: NSColor = .gray
    var hasBubbleArrow: Bool = true
    
    private var sections: [SectionItem] = []
    
    var points:[TimelinePoint] = [] {
        didSet {
            self.documentView?.layer?.sublayers?.forEach({ (layer) in
                if layer.isKind(of: CAShapeLayer.self) {
                    layer.removeFromSuperlayer()
                }
            })
            self.documentView?.subviews.forEach { (view) in
                view.removeFromSuperview()
            }
            
//            self.contentSize = CGSize.zero
            self.documentView?.setFrameSize(.zero)
            
            self.sections.removeAll()
            self.buildSections()
            
            layer?.setNeedsDisplay()
            layer?.displayIfNeeded()
        }
    }
    
    required override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initialize()
    }
    
    private func initialize() {
        
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
                self.drawBubble(item.bubbleRect, backgroundColor: self.bubbleColor, textColor: self.titleColor, titleLabel: item.titleLabel)
                
                if let descriptionLabel = item.descriptionLabel,
                    let descriptionRect = item.descriptionRect {
                    self.drawDescription(descriptionRect, textColor: self.descriptionColor, descriptionLabel: descriptionLabel)
                }
                
            }
        }
        
    }
    
    private func buildSections() {
        
        guard self.documentView != nil else {
            fatalError("The document view should not be nil")
        }
        
        self.setNeedsDisplay(self.bounds)
        self.needsLayout = true
      
        var y: CGFloat = self.documentView!.bounds.origin.y + self.contentInsets.top
        let maxWidth = self.calcWidth()
        for i in 0 ..< self.points.count {
            let titleLabel = self.buildTitleLabel(i)
            let descriptionLabel = self.buildDescriptionLabel(i)
            
            let titleHeight = titleLabel.intrinsicContentSize.height
            let descriptionHeight = descriptionLabel?.intrinsicContentSize.height ?? 0
            let height: CGFloat = titleHeight + descriptionHeight
        
            let point = CGPoint(x: self.bounds.origin.x + self.contentInsets.left + self.lineWidth / 2, y: y + (titleHeight + TimelineView.gap) / 2)
            
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
                height: titleHeight + TimelineView.gap)
            
            var descriptionRect: CGRect?
            if descriptionHeight > 0 {
                descriptionRect = CGRect(
                    x: bubbleRect.origin.x,
                    y: bubbleRect.origin.y + bubbleRect.height + 3,
                    width: maxWidth,
                    height: descriptionHeight)
            }
            
            self.sections.append((point, bubbleRect, descriptionRect, titleLabel, descriptionLabel, self.points[i].pointColor.cgColor, self.points[i].lineColor.cgColor, self.points[i].fill))
            
            y += height
            y += TimelineView.gap * 2.2
   
        }
        
        y += self.pointDiameter / 2
        let newContentSize = CGSize(width: self.bounds.width - (self.contentInsets.left + self.contentInsets.right), height: y)
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
    
    private func calcWidth() -> CGFloat {
        return self.bounds.width - (self.contentInsets.left + self.contentInsets.right) - self.pointDiameter - self.lineWidth - TimelineView.gap * 1.5
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
    
    private func drawBubble(_ rect: CGRect, backgroundColor: NSColor, textColor: NSColor, titleLabel: NSTextField) {
        let path = CGMutablePath.init()
        path.addRoundedRect(in: rect, cornerWidth: self.bubbleRadius, cornerHeight: self.bubbleRadius)
    
        if self.hasBubbleArrow {
            let startPont = CGPoint(x: rect.origin.x, y: rect.origin.y + rect.height / 2.0 - 8)
            path.move(to: startPont)
            path.addLine(to: startPont)
            path.addLine(to: CGPoint(x: rect.origin.x - 8, y: rect.origin.y + rect.height / 2))
            path.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.height / 2 + 8))
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path
        shapeLayer.fillColor = backgroundColor.cgColor
        
        self.documentView?.layer?.addSublayer(shapeLayer)
        
        let titleLabelHeight: CGFloat = 15.0
        let titleRect = CGRect(x: rect.origin.x + 10, y: rect.origin.y + (rect.size.height - titleLabelHeight) / 2  , width: rect.size.width - 15, height: titleLabelHeight)
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
