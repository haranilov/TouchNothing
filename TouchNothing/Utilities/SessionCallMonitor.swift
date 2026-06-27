import CallKit
import Foundation

final class SessionCallMonitor: NSObject {
    var onPhoneCall: (() -> Void)?

    private let callObserver = CXCallObserver()

    override init() {
        super.init()
        callObserver.setDelegate(self, queue: .main)
    }

    func endSessionIfPhoneCallIsActive() {
        guard callObserver.calls.contains(where: { !$0.hasEnded }) else { return }
        onPhoneCall?()
    }
}

extension SessionCallMonitor: CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        guard !call.hasEnded else { return }
        onPhoneCall?()
    }
}
