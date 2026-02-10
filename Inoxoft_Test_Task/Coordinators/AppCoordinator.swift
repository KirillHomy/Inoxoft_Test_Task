//


import UIKit
import SafariServices

class AppCoordinator: CoordinatorProtocol {

    // MARK: - External variables
    var navigationController: UINavigationController

    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - External Method
    func start() {
        setupMainViewController()
    }

}

// MARK: - External extension
extension AppCoordinator {

    func setupMainViewController() {
        let api = AlamofireAPIClient()
        let realmCache = PostsCacheRealmImpl()

        let repo = PostsRepositoryImpl(api: api, cache: realmCache)
        let useCase = FetchPostsUseCaseImpl(repo: repo)
        let vm = PostsViewModel(fetchUseCase: useCase)
        

        let vc = MainViewController(vm: vm)
        vc.appCoordinator = self

        navigationController.setViewControllers([vc], animated: false)
    }
    
    func openPostDetails(post: Post) {
        let vc = PostDetailsViewController(post: post)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func openPostInSafari(url: URL) {
        let safari = SFSafariViewController(url: url)
        navigationController.present(safari, animated: true)
    }
}

