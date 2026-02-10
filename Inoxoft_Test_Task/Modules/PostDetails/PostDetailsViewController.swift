//


import UIKit
import SnapKit
import Then

final class PostDetailsViewController: UIViewController {

    weak var coordinator: AppCoordinator?
    
    // MARK: - Data
    private let post: Post

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 22)
        $0.numberOfLines = 0
    }

    private let metaLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 0
    }

    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.backgroundColor = .secondarySystemBackground
        $0.layer.cornerRadius = 12
    }

    private let statsLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15)
        $0.textColor = .label
    }

    private let openButton = UIButton(type: .system).then {
        $0.setTitle("Open in Reddit", for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 16)
    }

    // MARK: - Init

    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configure()
    }
}

private extension PostDetailsViewController {

    func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Post"

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(metaLabel)
        contentView.addSubview(imageView)
        contentView.addSubview(statsLabel)
        contentView.addSubview(openButton)

        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        metaLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(titleLabel)
        }

        imageView.snp.makeConstraints {
            $0.top.equalTo(metaLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(titleLabel)
            $0.height.lessThanOrEqualTo(300)
        }

        statsLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(titleLabel)
        }

        openButton.snp.makeConstraints {
            $0.top.equalTo(statsLabel.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-32)
        }

        openButton.addTarget(self, action: #selector(openInReddit), for: .touchUpInside)
    }
}

private extension PostDetailsViewController {

    func configure() {
        titleLabel.text = post.title

        metaLabel.text = """
        \(post.author)
        \(post.subreddit)
        \(formattedDate(post.createdUTC))
        """

        statsLabel.text = "⬆️ \(post.score)   💬 \(post.comments)"

        if let imageURL = post.imageURL ?? post.thumbnailURL {
            imageView.isHidden = false
            loadImage(from: imageURL)
        } else {
            imageView.isHidden = true
        }
    }

    func formattedDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df.string(from: date)
    }
}

private extension PostDetailsViewController {

    func loadImage(from url: URL) {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let image = UIImage(data: data)

                await MainActor.run {
                    self.imageView.image = image
                }
            } catch {
                print("Image load failed:", error)
            }
        }
    }
}

private extension PostDetailsViewController {

    @objc private func openInReddit() {
        guard let url = post.permalink else { return }
        coordinator?.openPostInSafari(url: url)
    }
}
