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

private class TimelineSection: NSObject {
    
    var point: CGPoint
    var bubbleRect: CGRect
    var descriptionRect: CGRect?
    var titleLabel: NSTextField
    var descriptionLabel: NSTextField?
    var pointColor: CGColor
    var lineColor: CGColor
    var fill: Bool
    var onRight: Bool
    
    init(point: CGPoint, bubbleRect: CGRect, descriptionRect: CGRect?, titleLabel: NSTextField, descriptionLabel: NSTextField?, pointColor: CGColor, lineColor: CGColor, fill: Bool, onRight: Bool) {
        self.point = point
        self.bubbleRect = bubbleRect
        self.descriptionRect = descriptionRect
        self.titleLabel = titleLabel
        self.descriptionLabel = descriptionLabel
        self.pointColor = pointColor
        self.lineColor = lineColor
        self.fill = fill
        self.onRight = onRight
    }
    
}

private typealias SectionTuple = (point: CGPoint, bubbleRect: CGRect, descriptionRect: CGRect?, titleLabel: NSTextField, descriptionLabel: NSTextField?, pointColor: CGColor, lineColor: CGColor, fill: Bool, onRight: Bool, canBeDraw: Bool)

class TimelineView: NSView {
    
    private static let gap: CGFloat = 15.0
    private static let ContentMaxWidth: CGFloat = 800.0
    private static let BottomMargin: CGFloat = 50.0
    
    private var animation: NSAnimation? = nil
    private var sections: [SectionTuple] = []
    private var contentHeightSum: CGFloat = 0.0
    
    var contentInsets: NSEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
//            DispatchQueue.main.async {
//                self.refresh()
//            }
        }
    }
    
    var lineColor: NSColor = .gray
    
    var bubbleColor: NSColor = .gray {//.init(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0) {
        didSet {
//            DispatchQueue.main.async {
//                self.refresh()
//            }
        }
    }
    var titleColor: NSColor = .white {
        didSet {
//            DispatchQueue.main.async {
//                self.refresh()
//            }
        }
    }
    var descriptionColor: NSColor = .gray {
        didSet {
//            DispatchQueue.main.async {
//                self.refresh()
//            }
        }
    }
    var hasBubbleArrow: Bool = true {
        didSet {
//            DispatchQueue.main.async {
//                self.refresh()
//            }
        }
    }
    
    var bubbleArrowSize: NSSize = .init(width: 8, height: 16) {
        didSet {
            if bubbleArrowSize.width < 0.0 {
                bubbleArrowSize.width = 0.0
            }else if bubbleArrowSize.width > 10.0 {
                bubbleArrowSize.width = 10.0
            }
            if bubbleArrowSize.height < 0.0 {
                bubbleArrowSize.height = 0.0
            }else if bubbleArrowSize.height > 10.0 {
                bubbleArrowSize.height = 10.0
            }
//            DispatchQueue.main.async {
//                self.refresh()
//            }
        }
    }
    
    var pointDiameter: CGFloat = 8.0 {
        didSet {
            if pointDiameter < 0.0 {
                pointDiameter = 0.0
            }else if pointDiameter > 100.0 {
                pointDiameter = 100.0
            }
//            DispatchQueue.main.async {
//                self.refresh()
//            }
        }
    }
    
    var displayType: TimelineDisplayType = .both {
        didSet {
//            DispatchQueue.main.async {
//                self.refresh()
//            }
        }
    }
    
    var lineWidth: CGFloat = 1.2 {
        didSet {
            if lineWidth < 0.0 {
                lineWidth = 0.0
            }else if lineWidth > 20.0 {
                lineWidth = 20.0
            }
//            DispatchQueue.main.async {
//                self.refresh()
//            }
        }
    }
    
    var bubbleRadius: CGFloat = 4.0 {
        didSet {
            if bubbleRadius < 0.0 {
                bubbleRadius = 0.0
            }else if bubbleRadius > 6.0 {
                bubbleRadius = 6.0
            }
//            DispatchQueue.main.async {
//                self.refresh()
//            }
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
//            DispatchQueue.main.async {
//                self.refresh()
//            }
        }
    }
    
    var mouseEndPoint: NSPoint = NSZeroPoint {
        didSet {
//            DispatchQueue.main.async {
//                self.refresh()
//            }
        }
    }
    
    var mouseDraggingPoint: NSPoint = NSZeroPoint {
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
        
        self.layer?.sublayers?.forEach({ (layer) in
            if layer.isKind(of: CAShapeLayer.self) ||
                layer.isKind(of: CATextLayer.self) {
                layer.removeFromSuperlayer()
            }
        })
        self.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        self.updateSections()
     
        self.layer?.setNeedsDisplay()
        self.layer?.displayIfNeeded()
        self.setNeedsDisplay(self.bounds)
    }

    private func rebuild() {
        
        self.sections.removeAll()
        self.buildSections()
  
    }
    
    private func sectionMaxWidth() -> CGFloat {
        let availableWidth: CGFloat = TimelineView.ContentMaxWidth
        let width = availableWidth - (self.contentInsets.left + self.contentInsets.right) - self.pointDiameter - self.lineWidth - TimelineView.gap * 2
        return self.displayType == .both ? width / 2 : width
    }
    
    private func pointX() -> CGFloat {
        //TODO: Update to the new demand
        return self.mouseStartPoint.x
        /*
        switch self.displayType {
        case .left:
            return NSMaxX(self.bounds) - self.contentInsets.right - self.lineWidth / 2
        case .right:
            return NSMinX(self.bounds) + self.contentInsets.left + self.lineWidth / 2
        case .both:
            return (NSWidth(self.bounds) - self.contentInsets.left - self.contentInsets.right) / 2.0 - self.lineWidth / 2
        }
         */
    }
    
    private func maxY() -> CGFloat {
//        return self.bounds.height - self.contentInsets.top
        //TODO: Update to the new demand
        return self.mouseStartPoint.y
    }
    
    private func isOnRightSide(_ index: Int) -> Bool {
        if self.displayType == .both {
            return index % 2 == 0
        }else {
            return self.displayType == .right ? true : false
        }
    }
    
    private func buildSections() {
        
        let maxWidth = self.sectionMaxWidth()
        let sectionInterval: CGFloat = 5.0
        let labelInterval: CGFloat = 3.0
        var contentHeight: CGFloat = 0.0
        
        for i in (0..<self.points.count) {
            
            let section = self.points[i]
            let titleLabel = self.buildTitleLabel(i)
            titleLabel.preferredMaxLayoutWidth = maxWidth
            let bubbleHeight = titleLabel.intrinsicContentSize.height + 10
            
            let descriptionLabel = self.buildDescriptionLabel(i)
            descriptionLabel?.preferredMaxLayoutWidth = maxWidth
            let descriptionHeight = descriptionLabel?.intrinsicContentSize.height ?? 0
            let sectionHeight: CGFloat = bubbleHeight + descriptionHeight
            
            let bubbleWidth = min(titleLabel.intrinsicContentSize.width + 20, maxWidth)
            
            let bubbleRect = CGRect(
                x: 0,
                y: 0,
                width: bubbleWidth,
                height: bubbleHeight)
            
            var descriptionRect: CGRect = .zero
            if descriptionHeight > 0 {
                descriptionRect = CGRect(
                    x: 0,
                    y: 0,
                    width: maxWidth,
                    height: descriptionHeight)
            }
           
            let onRight: Bool = self.isOnRightSide(i)
            
            descriptionLabel?.alignment = onRight ? .left : .right
            
            self.sections.append((.zero, bubbleRect, descriptionRect, titleLabel, descriptionLabel, section.pointColor.cgColor, section.lineColor.cgColor, section.fill, onRight: onRight, canBeDraw: false))
            
            contentHeight += sectionHeight
            contentHeight += sectionInterval
            contentHeight += labelInterval
        }
    
        self.contentHeightSum = contentHeight
        print(self.contentHeightSum)
    }
    
    private func updateSections() {
        
        guard self.isFlipped == false else {
            fatalError("The view MUST be flipped...")
        }
        
        self.updateSectionsInNonFlippedCoordinateSystemView()
        
    }
    
    private func updateSectionsInNonFlippedCoordinateSystemView() {
       
        let titleLabelHeight: CGFloat = 15.0
        let pointX = self.pointX()
        let maxY = self.maxY()
        let maxWidth = self.sectionMaxWidth()
        let sectionInterval: CGFloat = 5.0
        let labelInterval: CGFloat = 3.0
        let draggingY: CGFloat = self.mouseDraggingPoint.y
        var sectionBaseY = draggingY + TimelineView.BottomMargin
        let availableHeight = maxY - draggingY - TimelineView.BottomMargin
        var curContentHeight: CGFloat = 0.0
        
        if availableHeight >= self.contentHeightSum + TimelineView.gap {
            sectionBaseY = maxY - self.contentHeightSum - TimelineView.gap
        }
        
        for i in (0..<self.sections.count).reversed() {
            
            //In Swift: A value copy happened here cause the section variable is a value type rather than a class type
            //In other word, if you wanna change the property of section in the array named "sections", you MUST access the array directly
            let section = self.sections[i]
            
            let bubbleWidth = section.bubbleRect.width
            let bubbleHeight = section.bubbleRect.height
            let descHeight = section.descriptionRect?.height ?? 0
            let sectionHeight: CGFloat = bubbleHeight + descHeight
            
            self.sections[i].canBeDraw = (availableHeight < curContentHeight + sectionHeight) ? false : true
            
            if self.sections[i].canBeDraw == false {
                break
            }
            
            let offset: CGFloat = self.hasBubbleArrow ? 13 : 5
            let onRight: Bool = section.onRight
            
            let bubblePointX = onRight ? pointX + self.pointDiameter + offset : pointX - bubbleWidth - offset - self.pointDiameter
            let descPointX = onRight ? bubblePointX : pointX - maxWidth - offset - self.pointDiameter
            
            let descPointY = sectionBaseY + curContentHeight
            let bubbltPointY = descPointY + descHeight + labelInterval + sectionInterval
            
            let point = CGPoint(x: pointX - self.pointDiameter / 2, y: bubbltPointY + bubbleHeight / 2 - self.pointDiameter / 2)
      
            self.sections[i].point = point
            self.sections[i].bubbleRect.origin = .init(x: bubblePointX, y: bubbltPointY)
            self.sections[i].descriptionRect?.origin = .init(x: descPointX, y: descPointY)
           
            let titleFrame = CGRect(x: bubblePointX + 10, y: bubbltPointY + (bubbleHeight - titleLabelHeight) / 2  , width: bubbleWidth - 10, height: titleLabelHeight)
            self.updateLabel(section.titleLabel, frame: titleFrame, textColor: self.titleColor)
            
            if let label = section.descriptionLabel, let rect = self.sections[i].descriptionRect {
                let descFrame = NSOffsetRect(rect, 10, 0)
                self.updateLabel(label, frame: descFrame, textColor: self.descriptionColor)
            }
            
            curContentHeight += sectionHeight
            curContentHeight += sectionInterval
            curContentHeight += labelInterval
            
        }
        
    }
  
    private func buildTitleLabel(_ index: Int) -> NSTextField {
        let label = NSTextField.init()
        label.stringValue = points[index].title
        label.font = .systemFont(ofSize: 12.0)
        label.isBordered = false
        label.isEditable = false
        label.isSelectable = true
        label.focusRingType = .none
        label.drawsBackground = true
        label.backgroundColor = .clear
        label.lineBreakMode = .byWordWrapping
        label.canDrawSubviewsIntoLayer = true
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
            label.drawsBackground = true
            label.backgroundColor = .clear
            label.lineBreakMode = .byWordWrapping
            label.canDrawSubviewsIntoLayer = true
            return label
        }else {
            return nil
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        self.saveGState { (cgContext) in
            
            if self.sections.count > 0 {
                
                let start: NSPoint = .init(x: self.pointX(), y: self.mouseDraggingPoint.y)
                let endY = self.maxY()
                let end: NSPoint = .init(x: start.x, y: endY)
                
                self.drawLine(start, end: end, color: self.lineColor.cgColor)
                
                let knobPointDiameter: CGFloat = 3.0
                self.drawPoint(NSPoint.init(x: start.x - knobPointDiameter / 2, y: start.y - knobPointDiameter / 2), diameter: knobPointDiameter, color: self.lineColor.cgColor, fill: true, lineWidth: 1.0)
                
                let knobWidth: CGFloat = 60
                let knobHeight: CGFloat = 30
                let knobRect = NSRect.init(x: start.x + (self.hasBubbleArrow ? self.bubbleArrowSize.width : 0.0),
                                           y: start.y - knobHeight / 2.0,
                                           width: knobWidth,
                                           height: knobHeight)
                self.drawDraggingKnob(knobRect, backgroundColor: self.bubbleColor, onRight: true)
                
                self.sections.forEach { (section) in
                    
                    if section.canBeDraw {
                        self.drawPoint(section.point, diameter: self.pointDiameter , color: section.pointColor, fill: section.fill, lineWidth: self.lineWidth)
                        self.drawBubble(section.bubbleRect, backgroundColor: self.bubbleColor, onRight: section.onRight)
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
    
    private func drawPoint(_ point: CGPoint, diameter: CGFloat, color: CGColor, fill: Bool, lineWidth: CGFloat) {
        let path = CGPath.init(ellipseIn: CGRect(x: point.x, y: point.y, width: diameter, height: diameter), transform: nil)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path
        shapeLayer.strokeColor = color
        shapeLayer.fillColor = fill ? color : .clear
        shapeLayer.lineWidth = lineWidth
        
        self.layer?.addSublayer(shapeLayer)
    }
    
    private func drawBubble(_ rect: CGRect, backgroundColor: NSColor, onRight: Bool) {
        let path = CGMutablePath.init()
        path.addRoundedRect(in: rect, cornerWidth: self.bubbleRadius, cornerHeight: self.bubbleRadius)
    
        if self.hasBubbleArrow && self.bubbleArrowSize != .zero {
            let pointX = onRight ? NSMinX(rect) : NSMaxX(rect)
            let arrowPointX = onRight ? pointX - self.bubbleArrowSize.width : pointX + self.bubbleArrowSize.width
            let startPont = CGPoint(x: pointX , y: rect.origin.y + (rect.height - self.bubbleArrowSize.height) / 2.0 )
            path.move(to: startPont)
            path.addLine(to: CGPoint(x: arrowPointX, y: rect.origin.y + rect.height / 2))
            path.addLine(to: CGPoint(x: pointX, y: rect.origin.y + (rect.height + self.bubbleArrowSize.height) / 2))
            path.closeSubpath()
        }
       
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path
        shapeLayer.fillColor = backgroundColor.cgColor
        
        self.layer?.insertSublayer(shapeLayer, below: nil)
        
    }
    
    private func drawDraggingKnob(_ rect: CGRect, backgroundColor: NSColor, onRight: Bool) {
        let path = CGMutablePath.init()
        path.addRoundedRect(in: rect, cornerWidth: self.bubbleRadius, cornerHeight: self.bubbleRadius)
        
        if self.hasBubbleArrow && self.bubbleArrowSize != .zero {
            let pointX = onRight ? NSMinX(rect) : NSMaxX(rect)
            let arrowPointX = onRight ? pointX - self.bubbleArrowSize.width : pointX + self.bubbleArrowSize.width
            let startPont = CGPoint(x: pointX , y: rect.origin.y + (rect.height - self.bubbleArrowSize.height) / 2.0 )
            path.move(to: startPont)
            path.addLine(to: CGPoint(x: arrowPointX, y: rect.origin.y + rect.height / 2))
            path.addLine(to: CGPoint(x: pointX, y: rect.origin.y + (rect.height + self.bubbleArrowSize.height) / 2))
            path.closeSubpath()
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path
        shapeLayer.fillColor = backgroundColor.cgColor
        
        self.layer?.insertSublayer(shapeLayer, below: nil)
        
    }
    
    private func updateLabel(_ label: NSTextField , frame: CGRect, textColor: NSColor) {
        label.textColor = textColor
        label.frame = frame
        self.addSubview(label)
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

extension TimelineView: ScreenDragTackingViewProtocol {
    func draggingTrack(_ track: DraggingTacker, willBeginAt screenPoint: NSPoint) {
        if self.animation != nil {
            self.animation?.removeObserver(self, forKeyPath: "currentProgress")
            self.animation?.stop()
            self.animation = nil
        }
        let locationInWindow = self.window!.convertFromScreen(.init(origin: screenPoint, size: .zero)).origin
        let point = self.convert(locationInWindow, to: self)
        self.mouseStartPoint = point
        print("\(#function) screen point: \(screenPoint)")
    }
    
    func draggingTrack(_ track: DraggingTacker, movedTo screenPoint: NSPoint) {
        let locationInWindow = self.window!.convertFromScreen(.init(origin: screenPoint, size: .zero)).origin
        let point = self.convert(locationInWindow, to: self)
        self.mouseDraggingPoint = point
//        print("\(#function) screen point: \(screenPoint)")
    }
    
    func draggingTrack(_ track: DraggingTacker, endedAt screenPoint: NSPoint) {
        let locationInWindow = self.window!.convertFromScreen(.init(origin: screenPoint, size: .zero)).origin
        let point = self.convert(locationInWindow, to: self)
        self.mouseEndPoint = point
        let distance: CGFloat = self.mouseStartPoint.y - self.mouseEndPoint.y
        let duration: CGFloat = max(0, distance * 0.0015)
        print("duration: \(duration)")
        self.addAnimation(duration)
//        print("\(#function) screen point: \(screenPoint)")
    }
}
/*
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
        let distance: CGFloat = self.mouseEndPoint.y - self.mouseStartPoint.y
        let duration: CGFloat = distance * 0.0001
        print("duration: \(duration)")
        self.addAnimation(duration)
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseUp(with: event)
        let point = self.convert(event.locationInWindow, to: self)
        self.mouseDraggingPoint = point
//        print("mouse dragged \(point)")
        
    }
    
}
 */

extension TimelineView: NSAnimationDelegate {
    
    private func addAnimation(_ duration: CGFloat) {
        if self.animation == nil {
            let animation = NSAnimation.init(duration: TimeInterval(duration), animationCurve: .linear)
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
            let currentPointY = self.maxY() - (self.mouseStartPoint.y - self.mouseEndPoint.y) * CGFloat(1 - progress)
            self.mouseDraggingPoint = .init(x: self.mouseStartPoint.x, y: currentPointY)
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


