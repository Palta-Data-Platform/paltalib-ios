//

import PaltaLibAnalytics
import PaltaLibAnalyticsModel
import PaltaAnlyticsTransport

public extension Stack {
    static let `default` = Stack(
        batchCommon: PaltaAnlyticsTransport.BatchCommon.self,
        context: Context.self,
        batch: PaltaAnlyticsTransport.Batch.self,
        event: PaltaAnlyticsTransport.Event.self,
        sessionStartEventType: 1,
        eventHeader: EventHeader.self,
        sessionStartEventPayload: EventPayloadSessionStart.self
    )
}

extension EventPayloadSessionStart: PaltaLibAnalyticsModel.SessionStartEventPayload {
    
}

@objc(PBEventsWiring)
private class EventsWiring: NSObject {
    @objc
    func wireStack() {
        PaltaAnalytics.initiate(with: .default)
    }
}
