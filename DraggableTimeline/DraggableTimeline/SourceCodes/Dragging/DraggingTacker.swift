//
//  DraggingTacker.swift
//  DraggableTimeline
//
//  Created by caowanping on 2019/11/8.
//  Copyright © 2019 industriousguy. All rights reserved.
//

import Cocoa

/*
extension DraggingTacker {
    static let startScreenPointKVOPath = "startScreenPoint"
    static let draggingScreenPoint = "draggingScreenPoint"
    static let endScreenPointKVOPath = "endScreenPoint"
}
*/

protocol ScreenDragTackingViewProtocol {
    func draggingTrack(_ track: DraggingTacker, willBeginAt screenPoint: NSPoint)
    func draggingTrack(_ track: DraggingTacker, movedTo screenPoint: NSPoint)
    func draggingTrack(_ track: DraggingTacker, endedAt screenPoint: NSPoint)
}

class DraggingTacker: NSObject {
    
    private let draggingOverlay = DraggingOverlay.init()
    
    /*
     @objc dynamic var startScreenPoint: NSPoint = .zero
     @objc dynamic var draggingScreenPoint: NSPoint = .zero
     @objc dynamic var endScreenPoint: NSPoint = .zero
     */
  
    static let shared = DraggingTacker.init()
    
    private var delegate: ScreenDragTackingViewProtocol? = nil
    
    private override init() {
        super.init()
    }
    
    override func copy() -> Any {
        return self
    }
    
    override func mutableCopy() -> Any {
        return self
    }
    
    func setScreenDragTrackingView<T: NSView>(_ view: T) where T: ScreenDragTackingViewProtocol {
        DispatchQueue.main.async {
            self.delegate = view
            self.draggingOverlay.setConentView(view)
        }
    }
}

extension DraggingTacker {
    
    public func trackDrag(forMouseDownEvent event: NSEvent, in source: NSView) {
        if let pasteboardItem = NSPasteboardItem(pasteboardPropertyList: "", ofType: kUTTypeData as NSPasteboard.PasteboardType) {
            let item = NSDraggingItem(pasteboardWriter:pasteboardItem)
            item.draggingFrame = source.frame
            let session = source.beginDraggingSession(with: [item], event: event, source: self)
            session.animatesToStartingPositionsOnCancelOrFail = false
        }
    }
    
}

extension DraggingTacker: NSDraggingSource {
    
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        switch context {
        case .withinApplication: return .generic
        case .outsideApplication: return []
        @unknown default:
            fatalError("")
        }
    }
    
    func draggingSession(_ session: NSDraggingSession, willBeginAt screenPoint: NSPoint) {
        /*
         self.startScreenPoint = screenPoint
         self.endScreenPoint = screenPoint
         self.draggingScreenPoint = screenPoint
         */
        self.delegate?.draggingTrack(self, willBeginAt: screenPoint)
        self.draggingOverlay.hide()
        self.draggingOverlay.show()
//        print("\(#function) screen point: \(screenPoint)")
    }

    func draggingSession(_ session: NSDraggingSession, movedTo screenPoint: NSPoint) {
        /*
         self.draggingScreenPoint = screenPoint
         */
        self.delegate?.draggingTrack(self, movedTo: screenPoint)
//        print("\(#function) screen point: \(screenPoint)")
    }

    func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        /*
         self.endScreenPoint = screenPoint
         self.draggingScreenPoint = screenPoint
         */
        self.delegate?.draggingTrack(self, endedAt: screenPoint)
//        print("\(#function) screen point: \(screenPoint)")
    }

    func ignoreModifierKeys(for session: NSDraggingSession) -> Bool {
        return true
    }
}

private class DraggingOverlay: NSObject {
    
    private lazy var overlayWindow: NSWindow = {
        let screen = NSScreen.screens[0]
        let styleMask = NSWindow.StyleMask.borderless
        let window = NSWindow(contentRect: .zero, styleMask: styleMask, backing: .buffered, defer: true, screen: screen)
        window.isReleasedWhenClosed = false
        window.ignoresMouseEvents = true
        window.setFrame(screen.frame, display: false)
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.isOneShot = true
        window.level = NSWindow.Level(1)
    
        window.contentView?.needsLayout = true
        
        return window
    }()
    
    func setConentView(_ view: NSView) {
        self.overlayWindow.contentView = view
    }
    
    func show(_ contentView: NSView? = nil) {
        if let view = contentView {
            self.overlayWindow.contentView = view
        }
        self.overlayWindow.orderFront(nil)
    }
    
    func hide() {
        self.overlayWindow.orderOut(nil)
    }
    
}
