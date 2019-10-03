import UIKit

final class RepositoryCell: UICollectionViewCell {
    static let reuseIdentifier = "RepositoryCell"
    
    private let nameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(repository: Repository) {
        nameLabel.text = repository.name
    }
}
