//
//  MediaKeyTap.swift
//  Castle
//
//  Created by Nicholas Hurden on 16/02/2016.
//  Copyright © 2016 Nicholas Hurden. All rights reserved.
//

import Cocoa

public enum MediaKey {
    case PlayPause
    case Previous
    case Next
    case Rewind
    case FastForward
}

public enum KeyPressMode {
    case KeyDown
    case KeyUp
    case KeyDownAndUp
}

public protocol MediaKeyTapDelegate {
    func handleMediaKey(mediaKey: MediaKey, event: KeyEvent)
}

public class MediaKeyTap {
    let delegate: MediaKeyTapDelegate
    let mediaApplicationWatcher: MediaApplicationWatcher
    let internals: MediaKeyTapInternals
    let keyPressMode: KeyPressMode

    var interceptMediaKeys: Bool {
        didSet {
            if interceptMediaKeys != oldValue {
                self.internals.enableTap(interceptMediaKeys)
            }
        }
    }

    // MARK: - Setup

    public init(delegate: MediaKeyTapDelegate, on mode: KeyPressMode = .KeyDown) {
        self.delegate = delegate
        self.interceptMediaKeys = false
        self.mediaApplicationWatcher = MediaApplicationWatcher()
        self.internals = MediaKeyTapInternals()
        self.keyPressMode = mode
    }

    public func start() {
        mediaApplicationWatcher.delegate = self
        mediaApplicationWatcher.start()

        internals.delegate = self
        internals.startWatchingMediaKeys()
    }

    private func keycodeToMediaKey(keycode: Keycode) -> MediaKey? {
        switch keycode {
        case NX_KEYTYPE_PLAY: return .PlayPause
        case NX_KEYTYPE_PREVIOUS: return .Previous
        case NX_KEYTYPE_NEXT: return .Next
        case NX_KEYTYPE_REWIND: return .Rewind
        case NX_KEYTYPE_FAST: return .FastForward
        default: return nil
        }
    }

    private func shouldNotifyDelegate(event: KeyEvent) -> Bool {
        switch keyPressMode {
        case .KeyDown:
            return event.keyPressed
        case .KeyUp:
            return !event.keyPressed
        case .KeyDownAndUp:
            return true
        }
    }
}

extension MediaKeyTap: MediaApplicationWatcherDelegate {
    func updateIsActiveMediaApp(active: Bool) {
        interceptMediaKeys = active
    }
}

extension MediaKeyTap: MediaKeyTapInternalsDelegate {
    func updateInterceptMediaKeys(intercept: Bool) {
        interceptMediaKeys = intercept
    }

    func handleKeyEvent(event: KeyEvent) {
        if let key = keycodeToMediaKey(event.keycode) {
            if shouldNotifyDelegate(event) {
                delegate.handleMediaKey(key, event: event)
            }
        }
    }

    func isInterceptingMediaKeys() -> Bool {
        return interceptMediaKeys
    }
}