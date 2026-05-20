import Foundation
import CoreServices

// Wraps FSEventStream and emits coalesced VaultEvents.
// Spec: openspec/changes/add-vault-storage/specs/vault/spec.md (Change notifications)
final class FileWatcher {
    typealias Handler = @Sendable ([VaultEvent]) -> Void

    private let root: URL
    private let handler: Handler
    private var stream: FSEventStreamRef?
    private let queue = DispatchQueue(label: "vault.watcher")

    init(root: URL, handler: @escaping Handler) {
        self.root = root
        self.handler = handler
    }

    func start() {
        guard stream == nil else { return }
        let info = Unmanaged.passRetained(WatcherContext(handler: handler)).toOpaque()
        var ctx = FSEventStreamContext(version: 0, info: info, retain: nil, release: { ptr in
            guard let ptr else { return }
            Unmanaged<WatcherContext>.fromOpaque(ptr).release()
        }, copyDescription: nil)

        let paths = [root.path] as CFArray
        guard let stream = FSEventStreamCreate(
            nil,
            { _, info, count, pathsPtr, flags, _ in
                guard let info else { return }
                let ctx = Unmanaged<WatcherContext>.fromOpaque(info).takeUnretainedValue()
                let cfArray = Unmanaged<CFArray>.fromOpaque(pathsPtr).takeUnretainedValue()
                let pathArray = (cfArray as NSArray) as? [String] ?? []
                let flagsBuf = UnsafeBufferPointer(start: flags, count: count)
                var events: [VaultEvent] = []
                for (i, path) in pathArray.enumerated() {
                    let url = URL(fileURLWithPath: path)
                    let f = flagsBuf[i]
                    if (f & UInt32(kFSEventStreamEventFlagItemRemoved)) != 0 {
                        events.append(.deleted(url))
                    } else if (f & UInt32(kFSEventStreamEventFlagItemCreated)) != 0 {
                        events.append(.created(url))
                    } else if (f & UInt32(kFSEventStreamEventFlagItemRenamed)) != 0 {
                        events.append(.modified(url))
                    } else if (f & UInt32(kFSEventStreamEventFlagItemModified)) != 0 {
                        events.append(.modified(url))
                    }
                }
                if !events.isEmpty { ctx.handler(events) }
            },
            &ctx,
            paths,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            0.1, // ~100 ms coalescing latency
            UInt32(kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes)
        ) else { return }

        FSEventStreamSetDispatchQueue(stream, queue)
        FSEventStreamStart(stream)
        self.stream = stream
    }

    func stop() {
        guard let stream else { return }
        FSEventStreamStop(stream)
        FSEventStreamInvalidate(stream)
        FSEventStreamRelease(stream)
        self.stream = nil
    }

    deinit { stop() }
}

private final class WatcherContext {
    let handler: FileWatcher.Handler
    init(handler: @escaping FileWatcher.Handler) { self.handler = handler }
}
