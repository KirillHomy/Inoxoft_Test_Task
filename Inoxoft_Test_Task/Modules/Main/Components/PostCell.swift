//


import UIKit
import Kingfisher

final class PostCell: UITableViewCell {
    static let reuseID = "PostCell"

    private let thumb = UIImageView()
    private let titleLabel = UILabel()
    private let metaLabel = UILabel()
    private var imageTask: Task<Void, Never>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        thumb.contentMode = .scaleAspectFill
        thumb.clipsToBounds = true
        thumb.layer.cornerRadius = 10
        thumb.backgroundColor = .secondarySystemBackground

        titleLabel.numberOfLines = 2
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)

        metaLabel.numberOfLines = 1
        metaLabel.font = .systemFont(ofSize: 12)
        metaLabel.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [titleLabel, metaLabel])
        stack.axis = .vertical
        stack.spacing = 6

        let root = UIStackView(arrangedSubviews: [thumb, stack])
        root.axis = .horizontal
        root.alignment = .top
        root.spacing = 12

        contentView.addSubview(root)
        root.translatesAutoresizingMaskIntoConstraints = false
        thumb.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            root.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            root.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            root.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            thumb.widthAnchor.constraint(equalToConstant: 80),
            thumb.heightAnchor.constraint(equalToConstant: 80),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()

        thumb.kf.cancelDownloadTask()
        thumb.image = nil

        titleLabel.text = nil
        metaLabel.text = nil
    }

    func configure(with post: Post) {
        titleLabel.text = post.title
        metaLabel.text = "\(post.author) • \(post.score)↑ • \(post.comments)💬"

        guard let url = post.bestImageURL else {
            thumb.kf.cancelDownloadTask()
            thumb.image = nil
            thumb.isHidden = true
            return
        }

        thumb.isHidden = false

        let processor = DownsamplingImageProcessor(size: CGSize(width: 80, height: 80))

        thumb.kf.setImage(
            with: url,
            placeholder: UIImage(systemName: "photo.stack.fill"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.25))
            ]
        )
    }

}
