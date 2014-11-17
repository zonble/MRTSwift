import UIKit

class RootTableViewController :UITableViewController {
	var from :String?
	var to: String?
	var fromPicker = ExitPicker(style: .Grouped)
	var toPicker = ExitPicker(style: .Grouped)
	var suggestedRoutes = [(String, MRTRoute)]()
	var onewayFare :Int32?
	var easycardFare :Int32?
	var reducedFare :Int32?
	var formatter = NSNumberFormatter()

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
		var backItem = UIBarButtonItem(title: "", style: .Bordered, target: nil, action: nil)
		self.navigationItem.backBarButtonItem = backItem
		self.formatter.numberStyle = .CurrencyStyle
		self.formatter.locale = NSLocale(localeIdentifier: "zh_Hant_TW")
	}

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if suggestedRoutes.count > 0 {
			return 4
		}
		return 2
	}
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 2 {
			return suggestedRoutes.count
		}
		if section == 3 {
			return 3
		}
		return 1
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell :UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
		if cell == nil {
			cell = UITableViewCell(style: .Value1, reuseIdentifier: "Cell")
		}
		if let cell = cell {
			cell.textLabel.textColor = UIColor.blackColor()
			cell.textLabel.textAlignment = .Left
			cell.selectionStyle = .Blue
			cell.detailTextLabel!.text = ""
			section: switch indexPath.section {
			case 0:
				cell.textLabel.text = self.from ?? "尚未設定"
				cell.accessoryType = .DisclosureIndicator
			case 1:
				cell.textLabel.text = self.to ?? "尚未設定"
				cell.accessoryType = .DisclosureIndicator
			case 2:
				var (title, route) = self.suggestedRoutes[indexPath.row]
				cell.textLabel.text = title
				cell.accessoryType = .DisclosureIndicator
				cell.detailTextLabel!.text = "共 \(route.links.count) 站，轉 \(route.transitions.count - 1)  次"
			case 3:
				cell.selectionStyle = .None
				cell.accessoryType = .None
				cell.textLabel.text = ["單程票", "悠遊卡", "敬老、愛心卡"][indexPath.row]
				row: switch indexPath.row {
				case 0:
					cell.detailTextLabel!.text = onewayFare != nil ? formatter.stringFromNumber(Int(onewayFare!)) : ""
				case 1:
					cell.detailTextLabel!.text = easycardFare != nil ? formatter.stringFromNumber(Int(easycardFare!)) : ""
				case 2:
					cell.detailTextLabel!.text = reducedFare != nil ? formatter.stringFromNumber(Int(reducedFare!)) : ""
				default:
					break
				}
			default:
				break
			}
		}
		return cell!
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

		func cal() {
			self.suggestedRoutes.removeAll(keepCapacity: false)
			self.tableView.reloadData()

			if self.from == nil { return }
			if self.to == nil { return }
			var routes = MRTMap.sharedMap.findRoutes(self.from!, toID: self.to!)
			if routes == nil { return }

			let routesSortedByExitcount = sorted(routes!, {
				if $0.links.count == $1.links.count {
					return $0.transitions.count < $1.transitions.count
				}
				return $0.links.count < $1.links.count
			})
			let routesSortedByTransitionCount = sorted(routes!, {
				if $0.transitions.count == $1.transitions.count {
					return $0.links.count < $1.links.count
				}
				return $0.transitions.count < $1.transitions.count
			})
			let routeWithFewestExits = routesSortedByExitcount[0]
			let routeWithFewestTransitions = routesSortedByTransitionCount[0]
			if (routeWithFewestExits === routeWithFewestTransitions) {
				self.suggestedRoutes.append(("建議路線", routeWithFewestExits))
			} else if (routeWithFewestExits.links.count == routeWithFewestTransitions.links.count) {
				self.suggestedRoutes.append(("建議路線", routeWithFewestTransitions))
			} else {
				self.suggestedRoutes.append(("車站最少路線", routeWithFewestExits))
				self.suggestedRoutes.append(("轉乘最少路線", routeWithFewestTransitions))
			}

			var fares = MRTPriceDatabase.sharedDatabase.price(self.from!, toStationName: self.to!)
			var (v1, v2, v3, _) = fares[0]
			self.onewayFare = v1
			self.easycardFare = v2
			self.reducedFare = v3
			self.tableView.reloadData()
		}

		cal()
		self.dismissViewControllerAnimated(true, completion:nil)
	}
}
