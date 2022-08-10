//  

import PaltaLibAnalytics
import PaltaLibAnalyticsModel
import PaltaAnalyticsTransport

extension Stack {
    public static let `default`: Stack = Stack(
        batchCommon: PaltaAnlyticsTransport.BatchCommon.self,
        context: Context.self,
        batch: PaltaAnlyticsTransport.Batch.self,
        event: PaltaAnlyticsTransport.Event.self,
        sessionStartEventType: 1,
        eventHeader: EventHeader.self,
        sessionStartEventPayloadProvider: { SessionStartEvent().payload }
    )
}

extension EventPayloadSessionStart: PaltaLibAnalyticsModel.SessionStartEventPayload {
}

@objc(PBEventsWiring)

private final class EventsWiring: NSObject {
    @objc
    private func wireStack() {
        PaltaAnalytics.initiate(with: .default)
    }
}
