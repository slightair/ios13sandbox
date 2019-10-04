import Foundation
import Combine
import APIKit

extension Session {
    struct Response<Request: APIKit.Request>: Publisher {
        typealias Output = Request.Response
        typealias Failure = SessionTaskError

        let session: Session
        let request: Request
        let callbackQueue: CallbackQueue?

        func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = RequestSubscription(subscriber: subscriber, session: session, request: request, callbackQueue: callbackQueue)
            subscriber.receive(subscription: subscription)
        }
    }

    class RequestSubscription<SubscriberType: Subscriber, Request: APIKit.Request>: Subscription where SubscriberType.Input == Request.Response, SubscriberType.Failure == SessionTaskError {
        let combineIdentifier = CombineIdentifier()

        let session: Session
        let request: Request
        let callbackQueue: CallbackQueue?

        var subscriber: SubscriberType?
        var sessionTask: SessionTask?

        init(subscriber: SubscriberType, session: Session, request: Request, callbackQueue: CallbackQueue?) {
            self.subscriber = subscriber
            self.session = session
            self.request = request
            self.callbackQueue = callbackQueue
        }

        func request(_ demand: Subscribers.Demand) {
            sessionTask = session.send(request, callbackQueue: callbackQueue) { result in
                switch result {
                case .success(let response):
                    _ = self.subscriber?.receive(response)
                    self.subscriber?.receive(completion: .finished)
                case .failure(let error):
                    self.subscriber?.receive(completion: .failure(error))
                }
            }
        }

        func cancel() {
            sessionTask?.cancel()
            subscriber = nil
        }
    }

    class func publisher<Request: APIKit.Request>(for request: Request, callbackQueue: CallbackQueue? = nil) -> Response<Request> {
        return Response(session: shared, request: request, callbackQueue: callbackQueue)
    }

    func publisher<Request: APIKit.Request>(for request: Request, callbackQueue: CallbackQueue? = nil) -> Response<Request> {
        return Response(session: self, request: request, callbackQueue: callbackQueue)
    }
}
