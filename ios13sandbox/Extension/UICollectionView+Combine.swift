import UIKit
import Combine

extension Subscribers {
    final class Apply<SectionIdentifier, ItemIdentifier>: Subscriber, Cancellable where SectionIdentifier: Hashable, ItemIdentifier: Hashable {
        typealias Input = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>
        typealias Failure = Never
        typealias DataSource = UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>

        private let diffableDataSource: DataSource
        private let animatingDifferences: Bool
        private let completion: (() -> Void)?

        private var subscription: Subscription?

        init(diffableDataSource: DataSource, animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {
            self.diffableDataSource = diffableDataSource
            self.animatingDifferences = animatingDifferences
            self.completion = completion
        }

        func receive(_ input: Input) -> Subscribers.Demand {
            diffableDataSource.apply(input, animatingDifferences: animatingDifferences, completion: completion)
            return .none
        }

        func receive(subscription: Subscription) {
            self.subscription = subscription
            subscription.request(.unlimited)
        }

        func receive(completion: Subscribers.Completion<Never>) {}

        func cancel() {
            subscription?.cancel()
        }
    }
}

extension Publisher {
    func apply<SectionIdentifier, ItemIdentifier>(to diffableDataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>, animatingDifferences: Bool = true, completion: (() -> Void)? = nil) -> AnyCancellable where Output == NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>, Failure == Never {
        let apply = Subscribers.Apply<SectionIdentifier, ItemIdentifier>(diffableDataSource: diffableDataSource, animatingDifferences: animatingDifferences, completion: completion)
        receive(subscriber: apply)
        return AnyCancellable(apply)
    }
}
