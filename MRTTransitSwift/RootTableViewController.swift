import UIKit

class RootTableViewController :UITableViewController {
	var from :String?
	var to: String?
	var fromPicker = ExitPicker(style: .Grouped)
	var toPicker = ExitPicker(style: .Grouped)
	var suggestedRoutes = [(String, MRTRoute)]()

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		fromPicker.delegate = self
		toPicker.delegate = self
	}

	override init(style: UITableViewStyle) {
		super.init(style: style)
		fromPicker.delegate = self
		toPicker.delegate = self
	}

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		fromPicker.delegate = self
		toPicker.delegate = self
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "台北捷運轉乘"
		self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		var backItem = UIBarButtonItem(title: "", style: .Bordered, target: nil, action: nil)
		self.navigationItem.backBarButtonItem = backItem
	}

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if suggestedRoutes.count > 0 {
			return 4
		}
		return 3
	}
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 3 {
			return suggestedRoutes.count
		}
		return 1
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
		cell.textLabel.textColor = UIColor.blackColor()
		cell.textLabel.textAlignment = .Left
		switch indexPath.section {
		case 0:
			cell.textLabel.text = self.from ?? "Not Set Yet"
			cell.accessoryType = .DisclosureIndicator
		case 1:
			cell.textLabel.text = self.to ?? "Not Set Yet"
			cell.accessoryType = .DisclosureIndicator
		case 2:
			cell.textLabel.text = "Go!"
			cell.accessoryType = .None
			cell.textLabel.textColor = UIColor.blueColor()
			cell.textLabel.textAlignment = .Center
		case 3:
			var (title, _) = self.suggestedRoutes[indexPath.row]
			cell.textLabel.text = title
			cell.accessoryType = .DisclosureIndicator
		default:
			break
		}
		return cell
	}

	func cal() {
		self.suggestedRoutes.removeAll(keepCapacity: false)
		self.tableView.reloadData()

		if self.from == nil { return }
		if self.to == nil { return }
		var routes = MRTMap.sharedMap.findRoutes(self.from!, toID: self.to!)
		if routes == nil { return }

		let routesSortedByExitcount = sorted(routes!, {return $0.links.count < $1.links.count})
		let routesSortedByTransitionCount = sorted(routes!, {return $0.transitions.count < $1.transitions.count})
		let routeWithFewestExits = routesSortedByExitcount[0]
		let routeWithFewestTransitions = routesSortedByTransitionCount[0]
		if (routeWithFewestExits === routeWithFewestTransitions) {
			self.suggestedRoutes.append(("建議路線", routeWithFewestExits))
		} else {
			self.suggestedRoutes.append(("經過車站最少路線", routeWithFewestExits))
			self.suggestedRoutes.append(("轉乘次數最少路線", routeWithFewestTransitions))
		}
		self.tableView.reloadData()
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)

		func presentViewController(vc :UIViewController) {
			var nav = UINavigationController(rootViewController: vc)
			nav.preferredContentSize = CGSizeMake(320, 600)
			nav.modalPresentationStyle = UIModalPresentationStyle.Popover
			var cell = tableView.cellForRowAtIndexPath(indexPath)
			nav.popoverPresentationController!.sourceView = cell!
			nav.popoverPresentationController!.sourceRect = cell!.bounds
			self.presentViewController(nav, animated: true, completion: nil)
		}

		switch indexPath.section {
		case 0:
			presentViewController(fromPicker)
		case 1:
			presentViewController(toPicker)
		case 2:
			self.cal()
		case 3:
			let vc = RouteTableViewController(style: .Grouped)
			let (title, route) = self.suggestedRoutes[indexPath.row]
			vc.title = title
			vc.route = route
			var appDelegate :AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
			appDelegate.splitViewController!.showDetailViewController(UINavigationController(rootViewController: vc), sender: self)
		default:
			break
		}
	}

	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section < 2 {
			return ["請選擇起點", "請選擇終點"][section]
		}
		return nil
	}

}

extension RootTableViewController: ExitPickerDelegate {
	func exitPicker(picker: ExitPicker, didSelectStationName name:String) {
		if picker == self.fromPicker {
			self.from = name
		}
		else if picker == self.toPicker {
			self.to = name
		}
		self.suggestedRoutes.removeAll(keepCapacity: false)
		self.tableView.reloadData()
		self.dismissViewControllerAnimated(true, completion:nil)
	}
}
