import UIKit
import MapKit
import MRTLib

class MRTRouteViewController: UIViewController, UIActionSheetDelegate {
	lazy var tableViewController = MRTRouteTableViewController(style: .grouped)
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
		self.view.backgroundColor = UIColor.lightGray
		self.automaticallyAdjustsScrollViewInsets = true
		self.edgesForExtendedLayout = [.left, .right, .bottom]
		self.segmentedControl.frame = CGRect(x: 0, y: 0, width: 200, height: 32)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		segmentedControl.addTarget(self, action: #selector(changeTab(sender:)), for: UIControlEvents.valueChanged)
		segmentedControl.selectedSegmentIndex = 0
		tableViewController.view.frame = self.view.bounds
		tableViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		if #available(iOS 11.0, *) {
			self.navigationItem.largeTitleDisplayMode = .never
		}
		self.view.addSubview(tableViewController.view)
		self.title = nil
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.navigationItem.titleView = segmentedControl
	}

	@objc func changeTab(sender: Any?) {
		let segmentedControl = sender as! UISegmentedControl
		switch segmentedControl.selectedSegmentIndex {
		case 0:
			mapViewController.view.removeFromSuperview()
			mapViewController.removeFromParentViewController()
			self.navigationItem.rightBarButtonItem = nil
		case 1:
			mapViewController.view.frame = self.view.bounds
			mapViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			self.view.addSubview(mapViewController.view)
			self.addChildViewController(mapViewController)
			self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "地圖類型", style: .plain, target: self, action: #selector(changeMapType(sender:)))
		default:
			return
		}
	}

	@objc func changeMapType(sender: AnyObject?) {
		let actionSheet = UIActionSheet(title: "切斷地圖類型", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "標準", "衛星", "混合")
		actionSheet.show(in: self.view)
	}

	func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
		if buttonIndex < 1 {
			return
		}
		self.mapViewController.mapView?.mapType = [MKMapType.standard, MKMapType.satellite, MKMapType.hybrid][buttonIndex - 1]
	}
}
