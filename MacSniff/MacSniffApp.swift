//
//  MacSniffApp.swift
//  MacSniff
//
//  Created by Huw Rowlands on 18/7/21.
//

import AVFoundation
import SwiftUI

@main
struct MacSniffApp: App {

    let sniffer = Sniffer()

    var body: some Scene {
        WindowGroup {
            Image("schnoz")
                .frame(width: 350, height: 350, alignment: .center)
                .fixedSize()
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.willUpdateNotification), perform: { _ in
                    for window in NSApplication.shared.windows {
                        window.standardWindowButton(.zoomButton)?.isEnabled = false
                    }
                })
        }
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle())
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}

class Sniffer {

    private var mean: Int
    private var variation: Int

    private var players: [AVAudioPlayer] = [
        try! AVAudioPlayer(forResource: "achem", withExtension: "m4a"),
        try! AVAudioPlayer(forResource: "sniff", withExtension: "m4a")
    ]

    private var range: Range<Int> {
        let lower = mean - variation
        let higher = mean + variation
        return (lower..<higher)
    }

    init(mean: Int = 10, variation: Int = 3) {
        self.mean = mean
        self.variation = variation

        schedule(snort)
    }

    func schedule(_ snort: @escaping () -> Void) {
        let nextDelay = range.randomElement() ?? mean
        print("next snort in: \(nextDelay)")

        DispatchQueue.main.asyncAfter(deadline: .now() + Double(nextDelay)) { [weak self] in
            self?.snort()
        }
    }

    func snort() {
        print("snort")
        players.randomElement()?.play()
        schedule(snort)
    }
}

extension AVAudioPlayer {

    convenience init(forResource resource: String, withExtension fileExtension: String) throws {
        let path = Bundle.main.url(forResource: resource, withExtension: fileExtension)!

        try self.init(contentsOf: path)
    }

}
