//
//  TimelinePoint.swift
//  DraggableTimeline
//
//  Created by caowanping on 2019/11/2.
//  Copyright © 2019 industriousguy. All rights reserved.
//

import Cocoa

class TimelinePoint {
    
    var title: String
    var description: String?
    var pointColor: NSColor
    var lineColor: NSColor
    var fill: Bool
    
    public init(title: String, description: String, pointColor: NSColor, lineColor: NSColor, fill: Bool) {
        self.title = title
        self.description = description
        self.pointColor = pointColor
        self.lineColor = lineColor
        self.fill = fill
    }
    
    convenience init(title: String, description: String) {
        let defaultColor = NSColor.init(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
        self.init(title: title, description: description, pointColor: defaultColor, lineColor: defaultColor, fill: false)
    }
    
    convenience init(title: String) {
        self.init(title: title, description: "")
    }
}
