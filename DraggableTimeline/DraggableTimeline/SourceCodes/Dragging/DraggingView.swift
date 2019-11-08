//
//  DraggingView.swift
//  DraggableTimeline
//
//  Created by caowanping on 2019/11/8.
//  Copyright © 2019 industriousguy. All rights reserved.
//

import Cocoa

class DraggingView: NSView {
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        print(#function)
        guard sender.draggingSource is DraggingTacker else { return [] }
        return sender.draggingSourceOperationMask
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        print(#function)
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        print(#function)
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        print(#function)
        return true
    }
}
