//
//  AppDelegate.swift
//  DraggableTimeline
//
//  Created by caowanping on 2019/11/2.
//  Copyright © 2019 industriousguy. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var timeline: TimelineView!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: 20)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        self.addObservers()
        self.initStatusItem()
        self.initTimelineData()
        self.updateStatusBarImageView()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        self.window.makeKeyAndOrderFront(nil)
        return true
    }
    
    func initStatusItem() {
            
        let view = NSImageView.init(frame: NSRect.init(x: 0, y: 0, width: 20, height: 20))
        self.statusItem.view = view
        
        NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown]) { (event) -> NSEvent? in
            if event.window == self.statusItem.view?.window {
                self.statusItemButtonDidClicked(self.statusItem)
                    return nil
            }
            return event
        }
    }
        
    func statusItemButtonDidClicked(_ sender: Any) {
            
        if let source = statusItem.view, let mouseEvent = NSApp.currentEvent, mouseEvent.type == .leftMouseDown  {
            
            print(source.frame)
            //FIXME: To correct the center point x
            let centerPoint = NSPoint.init(x: NSMidX(source.frame), y: NSMidY(source.frame))

            let beginScreenPoint = source.window!.convertToScreen(.init(origin: centerPoint, size: .zero)).origin
            
            print("startPoint: \(beginScreenPoint)")

            DraggingTacker.shared.trackDragging(forMouseDownEvent: mouseEvent, in: source, beginAt: beginScreenPoint)
        }
        
    }
    
    private func updateStatusBarImageView() {
        if let imageView = self.statusItem.view as? NSImageView {
            let isDarkMode = UserDefaults.standard.isDarkMode()
            imageView.image = NSImage.init(imageLiteralResourceName: isDarkMode ? "statusicon_light" : "statusicon_dark")
        }
        
    }
            
}

extension AppDelegate {
    func addObservers() {
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(handleAppleInterfaceThemeChangedNotification(_:)), name: .AppleInterfaceThemeChanged, object: nil)
    }
    
    @objc func handleAppleInterfaceThemeChangedNotification(_ notification: NSNotification) {
        DispatchQueue.main.async {
            self.updateStatusBarImageView()
        }
    }
}

extension AppDelegate {
    
    private func initTimelineData() {
        
        let pointColor = NSColor.white
        let lineColor = NSColor.black
        
        let myPoints = [
            TimelinePoint(title: "06:46 AM", description: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam.", pointColor: pointColor, lineColor: lineColor, fill: false),
            TimelinePoint(title: "07:00 AM", description: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr.", pointColor: pointColor, lineColor: lineColor, fill: false),
            TimelinePoint(title: "07:30 AM", description: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam.", pointColor: pointColor, lineColor: lineColor, fill: false),
            TimelinePoint(title: "08:00 AM", description: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt.", pointColor: pointColor, lineColor: lineColor, fill: true),
            TimelinePoint(title: "11:30 AM", description: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam."),
            TimelinePoint(title: "02:30 PM", description: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam."),
            TimelinePoint(title: "05:00 PM", description: "Lorem ipsum dolor sit amet."),
            TimelinePoint(title: "08:15 PM", description: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam."),
            TimelinePoint(title: "11:45 PM", description: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam.")
        ]
        
        timeline.contentInsets = NSEdgeInsetsMake(20, 20, 20, 20)
        timeline.points = myPoints
        
        let timelineView = TimelineView.init(frame: .zero)
        DraggingTacker.shared.setScreenDragTrackingView(timelineView)
        timelineView.contentInsets = NSEdgeInsetsMake(20, 20, 20, 20)
        timelineView.points = myPoints
        
    }
}

