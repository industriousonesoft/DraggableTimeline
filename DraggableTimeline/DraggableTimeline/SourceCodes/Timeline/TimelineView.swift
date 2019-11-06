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

class TimelineView: NSView {
    
    private var animation: NSAnimation? = nil
    private static let gap: CGFloat = 15.0
    
    private var sections: [SectionItem] = []
    
    var contentInsets: NSEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
//            DispatchQueue.main.async {
//                self.refresh()
//            }
        }
    }
    
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
                self.rebuild()
            }
        }
    }
    
    var mouseStartPoint: NSPoint = NSZeroPoint {
        didSet {
            DispatchQueue.main.async {
                self.refresh()
            }
        }
    }
    
    var mouseEndPoint: NSPoint = NSZeroPoint {
        didSet {
            DispatchQueue.main.async {
                self.refresh()
            }
        }
    }
    
    var mouseDraggedPoint: NSPoint = NSZeroPoint {
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
        self.updateSections()
        
        self.layer?.setNeedsDisplay()
        self.layer?.displayIfNeeded()
    }
    
    private func rebuild() {
        self.layer?.sublayers?.forEach({ (layer) in
            if layer.isKind(of: CAShapeLayer.self) {
                layer.removeFromSuperlayer()
            }
        })
        self.subviews.forEach { (view) in
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
            return NSMaxX(self.bounds) - self.contentInsets.right - self.lineWidth / 2
        case .right:
            return NSMinX(self.bounds) + self.contentInsets.left + self.lineWidth / 2
        case .both:
            return (NSWidth(self.bounds) - self.contentInsets.left - self.contentInsets.right) / 2.0 - self.lineWidth / 2
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
        for i in (0..<self.points.count) {
            let item = self.points[i]
            let titleLabel = self.buildTitleLabel(i)
            let descriptionLabel = self.buildDescriptionLabel(i)
            
            let onRight: Bool = self.isOnRightSide(i)
            
            descriptionLabel?.alignment = onRight ? .left : .right
            
            self.sections.append((NSZeroPoint, NSZeroRect, NSZeroRect, titleLabel, descriptionLabel, item.pointColor.cgColor, item.lineColor.cgColor, item.fill, onRight: onRight))
        }
    }
    
    private func updateSections() {
        
        if self.isFlipped == false {
            self.updateSectionsInNonFlippedCoordinateSystemView()
        }else {
            self.updateSectionsInFlippedCoordinateSystemView()
        }
        
        self.setNeedsDisplay(self.bounds)
    }
    
    private func updateSectionsInNonFlippedCoordinateSystemView() {
       
        let pointX = self.timelinePointX()
        let maxY: CGFloat = self.bounds.height - self.contentInsets.top
        let y: CGFloat = self.mouseDraggedPoint.y
        let maxWidth = self.calcWidth()
        let itemInterval = TimelineView.gap * 2.5
        let labelInterval: CGFloat = 3.0
        var contentHeight: CGFloat = 0.0
        for i in (0..<self.sections.count).reversed() {
            
            var item = self.sections[i]
            let titleHeight = item.titleLabel.intrinsicContentSize.height
            let bubbleHeight = titleHeight + TimelineView.gap
            let descriptionHeight = item.descriptionLabel?.intrinsicContentSize.height ?? 0
            let height: CGFloat = titleHeight + descriptionHeight
            
            if maxY - y < contentHeight + height {
                break
            }
            
            let maxTitleWidth = maxWidth
            var titleWidth = item.titleLabel.intrinsicContentSize.width + 20
            if titleWidth > maxTitleWidth {
                titleWidth = maxTitleWidth
            }
            
            let offset: CGFloat = self.hasBubbleArrow ? 13 : 5
            let onRight: Bool = item.onRight
            
            let bubblePointX = onRight ? pointX + self.pointDiameter + offset : pointX - titleWidth - offset - self.pointDiameter
            let bubbltPointY = y + contentHeight + descriptionHeight + labelInterval
        
            let point = CGPoint(x: pointX, y: bubbltPointY + bubbleHeight / 2 - self.pointDiameter / 2)
            
            let bubbleRect = CGRect(
                x: bubblePointX,
                y: bubbltPointY,
                width: titleWidth,
                height: bubbleHeight)
            
            let desPointX = onRight ? bubbleRect.origin.x : pointX - maxWidth - offset - self.pointDiameter
            var descriptionRect: CGRect?
            if descriptionHeight > 0 {
                descriptionRect = CGRect(
                    x: desPointX,
                    y: y + contentHeight,
                    width: maxWidth,
                    height: descriptionHeight)
            }
            
            item.point = point
            item.bubbleRect = bubbleRect
            item.descriptionRect = descriptionRect
   
            contentHeight += height
            contentHeight += itemInterval
            contentHeight += labelInterval
            
        }
        
    }
    
    private func updateSectionsInFlippedCoordinateSystemView() {

        var y: CGFloat = self.bounds.origin.y + self.contentInsets.top
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
         
            let point = CGPoint(x: self.bounds.origin.x + self.contentInsets.left + self.lineWidth / 2, y: y + bubbleHeight / 2)
             
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
        let newContentSize = CGSize(width: self.bounds.width - (self.contentInsets.left + self.contentInsets.right), height: y)
        self.setFrameSize(newContentSize)
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
            
            if self.sections.count > 0 {
                
                let firstItem = self.sections[0]
                let start: NSPoint = .init(x: firstItem.point.x + self.pointDiameter / 2, y: self.mouseDraggedPoint.y)
                let endY = self.bounds.height - self.contentInsets.top //self.mouseStartPoint.y
                let end: NSPoint = .init(x: start.x, y: endY)
                
                self.drawLine(start, end: end, color: NSColor.green.cgColor)
                
                for i in 0 ..< self.sections.count {
                    
                    let item = self.sections[i]
                    
                    self.drawPoint(item.point, color: item.pointColor, fill: item.fill)
                    self.drawBubble(item.bubbleRect, backgroundColor: self.bubbleColor, textColor: self.titleColor, titleLabel: item.titleLabel, onRight: item.onRight)
                    
                    if let descriptionLabel = item.descriptionLabel,
                        let descriptionRect = item.descriptionRect {
                        self.drawDescription(descriptionRect, textColor: self.descriptionColor, descriptionLabel: descriptionLabel)
                    }
                    
                }
            }
        }
        
    }
    
    func drawLine(_ start: CGPoint, end: CGPoint, color: CGColor) {
        let path = CGMutablePath.init()
        path.move(to: start)
        path.addLine(to: end)
        path.closeSubpath()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = self.lineWidth
        
        self.layer?.addSublayer(shapeLayer)
    }
    
    private func drawPoint(_ point: CGPoint, color: CGColor, fill: Bool) {
        let path = CGPath.init(ellipseIn: CGRect(x: point.x, y: point.y, width: self.pointDiameter, height: self.pointDiameter), transform: nil)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path
        shapeLayer.strokeColor = color
        shapeLayer.fillColor = fill ? color : .clear
        shapeLayer.lineWidth = 1.0
        
        self.layer?.addSublayer(shapeLayer)
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
            path.closeSubpath()
        }
       
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path
        shapeLayer.fillColor = backgroundColor.cgColor
        
        self.layer?.addSublayer(shapeLayer)
        
        let titleLabelHeight: CGFloat = 15.0
        let titleRect = CGRect(x: rect.origin.x + 10, y: rect.origin.y + (rect.size.height - titleLabelHeight) / 2  , width: rect.size.width - 10, height: titleLabelHeight)
        titleLabel.textColor = textColor
        titleLabel.frame = titleRect
        self.addSubview(titleLabel)
        
    }
    
    private func drawDescription(_ rect: CGRect, textColor: NSColor, descriptionLabel: NSTextField) {
        descriptionLabel.textColor = textColor
        descriptionLabel.frame = CGRect(x: rect.origin.x + 7, y: rect.origin.y, width: rect.width - 10, height: rect.height)
        self.addSubview(descriptionLabel)
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

extension TimelineView {
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        if self.animation != nil {
            self.animation?.removeObserver(self, forKeyPath: "currentProgress")
            self.animation?.stop()
            self.animation = nil
        }
        let point = self.convert(event.locationInWindow, to: self)
        self.mouseStartPoint = point
//        print("mouse down \(point)")
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        let point = self.convert(event.locationInWindow, to: self)
        self.mouseEndPoint = point
//        print("mouse up \(point)")
        self.addAnimation()
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseUp(with: event)
        let point = self.convert(event.locationInWindow, to: self)
        self.mouseDraggedPoint = point
//        print("mouse dragged \(point)")
        
    }
    
}

extension TimelineView: NSAnimationDelegate {
    
    private func addAnimation() {
        if self.animation == nil {
            let animation = NSAnimation.init(duration: 2.0, animationCurve: .easeInOut)
            animation.delegate = self
            animation.animationBlockingMode = .nonblocking
            animation.start()
            self.animation = animation
            animation.addObserver(self, forKeyPath: "currentProgress", options: [.new], context: nil)
        }
        
    }
    
    func animationShouldStart(_ animation: NSAnimation) -> Bool {
        return true
    }
    
    func animationDidEnd(_ animation: NSAnimation) {
        print("animationDidEnd...")
    }
    
    func animationDidStop(_ animation: NSAnimation) {
        
    }
    
    @objc override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentProgress", let progress = change?[.newKey] as? NSAnimation.Progress {
            let currentPointY = self.mouseStartPoint.y - (self.mouseStartPoint.y - self.mouseEndPoint.y) * CGFloat(1 - progress)
            self.mouseDraggedPoint = .init(x: self.mouseStartPoint.x, y: currentPointY)
//            print("currentPointY => \(currentPointY)")
        }
    }
    
   
}

class CustomizedAnimation: NSAnimation {
    
    override init(duration: TimeInterval, animationCurve: NSAnimation.Curve) {
        super.init(duration: duration, animationCurve: animationCurve)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var currentProgress: NSAnimation.Progress {
        didSet {
            print("currentProgress => \(currentProgress)")
        }
    }
}

