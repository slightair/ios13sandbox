import APIKit
import UIKit

class RepositoryListViewController: UIViewController {
    enum Section: CaseIterable {
        case main
    }

    var dataSource: UICollectionViewDiffableDataSource<Section, Repository>!
    var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Repositories"

        configureSubviews()
        configureDataSource()

        performQuery(query: "swift")
    }

    private func performQuery(query: String) {
        let request = GitHubAPI.SearchRepositoriesRequest(query: query)
        Session.send(request) { result in
            switch result {
            case let .success(response):
                var snapshot = NSDiffableDataSourceSnapshot<Section, Repository>()

                snapshot.appendSections([.main])
                snapshot.appendItems(response.items)

                self.dataSource.apply(snapshot)
            case let .failure(error):
                print(error)
            }
        }
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
        dataSource = UICollectionViewDiffableDataSource<Section, Repository>(collectionView: collectionView) { collectionView, indexPath, repository in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RepositoryCell.reuseIdentifier, for: indexPath) as? RepositoryCell else {
                fatalError()
            }

            cell.update(repository: repository)

            return cell
        }
    }
}

extension RepositoryListViewController: UICollectionViewDelegate {}
