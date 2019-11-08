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
        self.initStatusItem()
        self.initTimelineData()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func initStatusItem() {
            
        let view = NSView.init(frame: NSRect.init(x: 0, y: 0, width: 20, height: 20))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.red.cgColor
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
            DraggingTacker.shared.trackDrag(forMouseDownEvent: mouseEvent, in: source)
        }
        
    }
            
}

extension AppDelegate {
    
    private func initTimelineData() {
        
        let black = NSColor.black
        let green = NSColor.init(red: 76/255, green: 175/255, blue: 80/255, alpha: 1)
        
        let myPoints = [
            TimelinePoint(title: "06:46 AM", description: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam.", pointColor: black, lineColor: black, fill: false),
            TimelinePoint(title: "07:00 AM", description: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr.", pointColor: black, lineColor: black, fill: false),
            TimelinePoint(title: "07:30 AM", description: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam.", pointColor: black, lineColor: black, fill: false),
            TimelinePoint(title: "08:00 AM", description: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt.", pointColor: green, lineColor: green, fill: true),
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

