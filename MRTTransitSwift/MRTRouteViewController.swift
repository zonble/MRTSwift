import UIKit
import MapKit

class MRTRouteViewController :UIViewController, UIActionSheetDelegate {
	lazy var tableViewController = MRTRouteTableViewController(style: .Grouped)
	lazy var mapViewController = MRTRouteMapViewController()
	lazy var segmentedControl = UISegmentedControl(items: ["路線", "地圖"])
	var route: MRTRoute? {
		didSet {
			tableViewController.route = self.route
			mapViewController.route = self.route
		}
	}

	override func loadView() {
		self.view = UIScrollView()
		self.view.backgroundColor = UIColor.lightGrayColor()
		self.automaticallyAdjustsScrollViewInsets = true
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		segmentedControl.addTarget(self, action: "changeTab:", forControlEvents: UIControlEvents.ValueChanged)
		segmentedControl.selectedSegmentIndex = 0
		tableViewController.view.frame = self.view.bounds
		tableViewController.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
		self.view.addSubview(tableViewController.view)
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationItem.titleView = segmentedControl
	}

	func changeTab(sender :AnyObject?) {
		var segmentedControl = sender as UISegmentedControl
		switch segmentedControl.selectedSegmentIndex {
		case 0:
			mapViewController.view.removeFromSuperview()
			mapViewController.removeFromParentViewController()
			self.navigationItem.rightBarButtonItem = nil
		case 1:
			mapViewController.view.frame = self.view.bounds
			mapViewController.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
			self.view.addSubview(mapViewController.view)
			self.addChildViewController(mapViewController)
			self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "地圖類型", style: .Plain, target: self, action: "changeMapType:")
		default:
			return
		}
	}

	func changeMapType(sender :AnyObject?) {
		let actionSheet = UIActionSheet(title: "切斷地圖類型", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "標準", "衛星", "混合")
		actionSheet.showInView(self.view)
	}

	func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
		if buttonIndex < 1 {
			return
		}
		self.mapViewController.mapView?.mapType = [MKMapType.Standard, MKMapType.Satellite, MKMapType.Hybrid][buttonIndex - 1]
	}
}