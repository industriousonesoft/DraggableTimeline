//
//  FlippedView.swift
//  DraggableTimeline
//
//  Created by caowanping on 2019/11/2.
//  Copyright © 2019 industriousguy. All rights reserved.
//

import Cocoa

class FlippedView: NSView {
    
    override var isFlipped: Bool {
        get {
            return false
        }
    }
}

extension FlippedView {
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        self.trackingAreas.forEach { (trackingArea) in
            self.removeTrackingArea(trackingArea)
        }
        self.addTrackingArea(.init(rect: self.bounds, options: [.mouseMoved, .activeAlways, .assumeInside], owner: nil, userInfo: nil))
    }
    
    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        let point = self.convert(event.locationInWindow, to: self)
        print(point)
    }
}

