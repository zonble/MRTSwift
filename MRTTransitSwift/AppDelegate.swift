import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var splitViewController: UISplitViewController?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		window = UIWindow(frame: UIScreen.main.bounds)
		let rootVC = MRTRootTableViewController(style: .grouped)
		splitViewController = UISplitViewController()
		if splitViewController!.traitCollection.horizontalSizeClass == .regular {
			splitViewController!.viewControllers = [UINavigationController(rootViewController: rootVC), UIViewController()]
		} else {
			splitViewController!.viewControllers = [UINavigationController(rootViewController: rootVC)]
		}

		splitViewController!.preferredDisplayMode = .allVisible
		window!.rootViewController = splitViewController
		window!.makeKeyAndVisible()
		return true
	}
}
