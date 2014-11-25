import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window :UIWindow?
	var splitViewController :UISplitViewController?
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		window = UIWindow(frame: UIScreen.mainScreen().bounds)
		var rootVC = MRTRootTableViewController(style: .Grouped)
		splitViewController = UISplitViewController()
		if splitViewController!.traitCollection.horizontalSizeClass == .Regular {
			splitViewController!.viewControllers = [UINavigationController(rootViewController: rootVC), UIViewController()]
		} else {
			splitViewController!.viewControllers = [UINavigationController(rootViewController: rootVC)]
		}

		splitViewController!.preferredDisplayMode = .AllVisible
		window!.rootViewController = splitViewController
		window!.makeKeyAndVisible()
		return true
	}
}
