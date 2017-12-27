import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var splitViewController: UISplitViewController?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		window = UIWindow(frame: UIScreen.main.bounds)
		let rootVC = MRTRootTableViewController(style: .grouped)
		splitViewController = UISplitViewController()
		let mainNav = UINavigationController(rootViewController: rootVC)
		if #available(iOS 11.0, *) {
			mainNav.navigationBar.prefersLargeTitles = true
		}
		if splitViewController?.traitCollection.horizontalSizeClass == .regular {
			splitViewController?.viewControllers = [mainNav, UIViewController()]
		} else {
			splitViewController?.viewControllers = [mainNav]
		}

		splitViewController?.preferredDisplayMode = .allVisible
		window?.rootViewController = splitViewController
		window?.makeKeyAndVisible()
		return true
	}
}
