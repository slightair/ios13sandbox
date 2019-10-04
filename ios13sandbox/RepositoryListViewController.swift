import APIKit
import UIKit
import Combine

class RepositoryListViewController: UIViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Repository>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Repository>

    enum Section: CaseIterable {
        case main
    }

    var dataSource: DataSource!
    var collectionView: UICollectionView!
    var requestCancellable: Cancellable?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Repositories"

        configureSubviews()
        configureDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        performQuery(query: "swift")
    }

    private func performQuery(query: String) {
        let request = GitHubAPI.SearchRepositoriesRequest(query: query)
        requestCancellable =
            Just(request)
                .flatMap { request in
                    Session
                        .publisher(for: request)
                        .map { response in
                            var snapshot = Snapshot()
                            snapshot.appendSections([.main])
                            snapshot.appendItems(response.items)
                            return snapshot
                        }
                        .catch { _ in Just(Snapshot()) }
                }
                .apply(to: dataSource)
    }
}

extension RepositoryListViewController {
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitem: item,
                                                       count: 2)
        let spacing = CGFloat(10)
        group.interItemSpacing = .fixed(spacing)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                        leading: 10,
                                                        bottom: 0,
                                                        trailing: 10)

        return UICollectionViewCompositionalLayout(section: section)
    }

    private func configureSubviews() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.register(RepositoryCell.self, forCellWithReuseIdentifier: RepositoryCell.reuseIdentifier)
        collectionView.delegate = self
        view.addSubview(collectionView)
    }

    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, repository in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RepositoryCell.reuseIdentifier, for: indexPath) as? RepositoryCell else {
                fatalError()
            }

            cell.update(repository: repository)

            return cell
        }
    }
}

extension RepositoryListViewController: UICollectionViewDelegate {}
