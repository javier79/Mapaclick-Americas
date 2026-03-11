//
//  DebugHelper.swift
//  mapaclick
//
//  Created by javier pizarro on 1/29/26.
//

import Foundation

// Change to false before App Store submission
let DEBUG_MODE = false

func debugPrint(_ message: String) {
    if DEBUG_MODE {
        print(message)
    }
}
