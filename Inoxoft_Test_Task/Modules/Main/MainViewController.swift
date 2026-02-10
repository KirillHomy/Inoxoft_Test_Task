//


import UIKit
import Then
import SnapKit

final class MainViewController: UIViewController {

    // MARK: - Weak variables
    weak var appCoordinator: AppCoordinator?

    // MARK: - Dependencies
    private let vm: PostsViewModel

    // MARK: - UI
    private let tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .singleLine
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 110
    }

    private let activity = UIActivityIndicatorView(style: .large).then {
        $0.hidesWhenStopped = true
    }
    private let footerActivity = UIActivityIndicatorView(style: .medium)
    private let searchController = UISearchController(searchResultsController: nil)
    private let refreshControl = UIRefreshControl()

    // MARK: - Init
    init(vm: PostsViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        bind()

        vm.loadInitial()
    }
}

// MARK: - Private setup
private extension MainViewController {

    func setupView() {
        view.backgroundColor = .white
        setupNavigationController()
        setupTable()
        setupLayout()
    }

    func setupNavigationController() {
        guard let nav = self.navigationController else { return }

        nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
        nav.navigationBar.shadowImage = UIImage()
        nav.navigationBar.isTranslucent = true
        nav.navigationBar.tintColor = .black
        title = "Test Task"

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search posts"
        searchController.searchBar.delegate = self

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    func setupTable() {
        tableView.register(PostCell.self, forCellReuseIdentifier: PostCell.reuseID)
        tableView.dataSource = self
        tableView.delegate = self

        refreshControl.addTarget(
            self,
            action: #selector(onPullToRefresh),
            for: .valueChanged
        )
        tableView.refreshControl = refreshControl
    }


    func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(activity)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        activity.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    func bind() {
        vm.onStateChange = { [weak self] state in
            guard let self else { return }

            // initial loader
            if state.isLoading && state.items.isEmpty {
                self.activity.startAnimating()
            } else {
                self.activity.stopAnimating()
            }

            // footer loader
            if state.isLoading && !state.items.isEmpty {
                self.showFooterLoader()
            } else {
                self.hideFooterLoader()
            }

            self.tableView.reloadData()

            // ✅ ОСТАНАВЛИВАЕМ pull-to-refresh
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }

            if let err = state.errorText {
                self.showError(err)
            }
        }
    }


    func showFooterLoader() {
        footerActivity.startAnimating()
        footerActivity.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
        tableView.tableFooterView = footerActivity
    }

    func hideFooterLoader() {
        footerActivity.stopAnimating()
        tableView.tableFooterView = nil
    }

    func showError(_ text: String) {
        let ac = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @objc private func onPullToRefresh() {
        vm.refresh()
    }

}

// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.state.items.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.reuseID,
                                                 for: indexPath) as! PostCell
        let post = vm.state.items[indexPath.row]
        cell.configure(with: post)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = vm.state.items[indexPath.row]
        appCoordinator?.openPostDetails(post: post)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentH = scrollView.contentSize.height
        let visibleH = scrollView.frame.height

        guard
            !vm.state.isLoading,
            vm.state.canLoadMore,
            vm.state.items.count > 0
        else { return }

        if offsetY > contentH - visibleH * 1.5 {
            Task { await vm.loadNextPage() }
        }
    }

}

// MARK: - UISearchResultsUpdating
extension MainViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }

        // debounce (чтобы не стрелять на каждый символ)
        NSObject.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(performSearch),
            object: nil
        )

        perform(#selector(performSearch), with: nil, afterDelay: 0.4)
    }

    @objc private func performSearch() {
        let query = searchController.searchBar.text ?? ""
        vm.search(query: query)
    }
}

// MARK: - UISearchBarDelegate
extension MainViewController: UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        vm.resetSearch()
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text?.isEmpty == true {
            vm.resetSearch()
        }
    }
}
