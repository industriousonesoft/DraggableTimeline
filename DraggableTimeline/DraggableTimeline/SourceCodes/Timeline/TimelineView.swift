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
    
    private var animation: NSAnimation? = nil
    private static let gap: CGFloat = 15.0
    
    private var sections: [SectionTuple] = []
    
    var contentInsets: NSEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
//            DispatchQueue.main.async {
//                self.refresh()
//            }
        }
    }
    
    var bubbleColor: NSColor = .clear {//.init(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0) {
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
    
    private func calcWidth() -> CGFloat {
        //TODO: Update to the new demand
//        let availableWidth = self.bounds.width
        let availableWidth: CGFloat = (self.bounds.width - self.pointX()) * 1.5
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
        for i in (0..<self.points.count) {
            let item = self.points[i]
            let titleLabel = self.buildTitleLabel(i)
            let descriptionLabel = self.buildDescriptionLabel(i)
            
            let onRight: Bool = self.isOnRightSide(i)
            !!在这个循环中算出当前item占用的总高度sumHeight，然后在updateSections更新y坐标，并当y距离maxY的高度大于在这个循环中算出当前item占用的总高度sumHeight，然后在updateSections更新y坐标，并当y距离maxY的高度大于时，item的y坐标不在随着y变化
            descriptionLabel?.alignment = onRight ? .left : .right
            
            self.sections.append((.zero, .zero, .zero, titleLabel, descriptionLabel, item.pointColor.cgColor, item.lineColor.cgColor, item.fill, onRight: onRight, canBeDraw: false))
        }
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
        let bottomMargin: CGFloat = 50.0
        let y: CGFloat = self.mouseDraggedPoint.y
        let maxWidth = self.calcWidth()
        let itemInterval: CGFloat = 5.0
        let labelInterval: CGFloat = 3.0
        var contentHeight: CGFloat = 0.0
        
        for i in (0..<self.sections.count).reversed() {
            
            let section = self.sections[i]
            let titleLabel = section.titleLabel
            titleLabel.preferredMaxLayoutWidth = maxWidth
            let bubbleHeight = titleLabel.intrinsicContentSize.height
            
            let descriptionLabel = section.descriptionLabel
            descriptionLabel?.preferredMaxLayoutWidth = maxWidth
            let descriptionHeight = descriptionLabel?.intrinsicContentSize.height ?? 0
            let height: CGFloat = bubbleHeight + descriptionHeight
            
            if maxY - y + bottomMargin < contentHeight + height {
                self.sections[i].point = .zero
                self.sections[i].bubbleRect = .zero
                self.sections[i].descriptionRect = .zero
                self.sections[i].canBeDraw = false
                break
            }
            
            let maxTitleWidth = maxWidth
            var titleWidth = section.titleLabel.intrinsicContentSize.width + 20
            if titleWidth > maxTitleWidth {
                titleWidth = maxTitleWidth
            }
            
            let offset: CGFloat = self.hasBubbleArrow ? 13 : 5
            let onRight: Bool = section.onRight
            
            let descriptionPointY = y + contentHeight + bottomMargin
            let bubblePointX = onRight ? pointX + self.pointDiameter + offset : pointX - titleWidth - offset - self.pointDiameter
            let bubbltPointY = descriptionPointY + descriptionHeight + labelInterval + itemInterval
        
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
                    y: descriptionPointY,
                    width: maxWidth,
                    height: descriptionHeight)
            }
            
            self.sections[i].point = point
            self.sections[i].bubbleRect = bubbleRect
            self.sections[i].descriptionRect = descriptionRect
            self.sections[i].canBeDraw = true
           
            let titleFrame = CGRect(x: bubbleRect.origin.x + 10, y: bubbleRect.origin.y + (bubbleRect.size.height - titleLabelHeight) / 2  , width: bubbleRect.size.width - 10, height: titleLabelHeight)
            self.updateLabel(titleLabel, frame: titleFrame, textColor: self.titleColor)
            
            if descriptionLabel != nil && descriptionRect != .zero {
                let descFrame = NSOffsetRect(descriptionRect!, 10, 0)
                self.updateLabel(descriptionLabel!, frame: descFrame, textColor: self.descriptionColor)
            }
            
            contentHeight += height
            contentHeight += itemInterval
            contentHeight += labelInterval
            
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
                
                let start: NSPoint = .init(x: self.pointX() + self.pointDiameter / 2, y: self.mouseDraggedPoint.y)
                let endY = self.maxY()
                let end: NSPoint = .init(x: start.x, y: endY)
                
                self.drawLine(start, end: end, color: NSColor.gray.cgColor)
                
                self.sections.forEach { (section) in
                    
                    if section.canBeDraw {
                        self.drawPoint(section.point, color: section.pointColor, fill: section.fill)
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
    
    private func drawPoint(_ point: CGPoint, color: CGColor, fill: Bool) {
        let path = CGPath.init(ellipseIn: CGRect(x: point.x, y: point.y, width: self.pointDiameter, height: self.pointDiameter), transform: nil)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path
        shapeLayer.strokeColor = color
        shapeLayer.fillColor = fill ? color : .clear
        shapeLayer.lineWidth = self.lineWidth
        
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
        self.mouseDraggedPoint = point
//        print("\(#function) screen point: \(screenPoint)")
    }
    
    func draggingTrack(_ track: DraggingTacker, endedAt screenPoint: NSPoint) {
        let locationInWindow = self.window!.convertFromScreen(.init(origin: screenPoint, size: .zero)).origin
        let point = self.convert(locationInWindow, to: self)
        self.mouseEndPoint = point
        let distance: CGFloat = self.mouseStartPoint.y - self.mouseEndPoint.y
        let duration: CGFloat = distance * 0.0015
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
        self.mouseDraggedPoint = point
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


