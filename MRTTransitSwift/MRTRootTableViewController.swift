import UIKit
import MRTLib

class MRTRootTableViewController: UITableViewController {
	var from: String?
	var to: String?
	var fromPicker = MRTExitPicker(style: .plain)
	var toPicker = MRTExitPicker(style: .plain)
	var suggestedRoutes = [(String, MRTRoute)]()
	var onewayFare: Int32?
	var easycardFare: Int32?
	var reducedFare: Int32?
	var time: Int32?
	var formatter = NumberFormatter()

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
		super.init(coder: aDecoder)!
		fromPicker.delegate = self
		toPicker.delegate = self
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "台北捷運轉乘"
		self.formatter.numberStyle = .currency
		self.formatter.locale = Locale(identifier: "zh_Hant_TW") as Locale!
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		NotificationCenter.default.addObserver(self, selector: Selector(("announcementDidFinish:")), name: NSNotification.Name.UIAccessibilityAnnouncementDidFinish, object: nil)
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		if suggestedRoutes.count > 0 {
			return 4
		}
		return 2
	}


	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 2 {
			return suggestedRoutes.count
		}
		if section == 3 {
			return 4
		}
		return 1
	}


	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "Cell")
		if cell == nil {
			cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
		}
		if let cell = cell {
			cell.textLabel?.textColor = UIColor.black
			cell.textLabel?.textAlignment = .left
			cell.selectionStyle = .blue
			cell.detailTextLabel!.text = ""
			cell.accessibilityHint = nil
			section: switch indexPath.section {
			case 0:
				cell.textLabel?.text = self.from ?? "尚未設定"
				cell.accessoryType = .disclosureIndicator
				cell.accessibilityHint = "點擊設定路線起點"
			case 1:
				cell.textLabel?.text = self.to ?? "尚未設定"
				cell.accessoryType = .disclosureIndicator
				cell.accessibilityHint = "點擊設定路線終點"
			case 2:
				let (title, route) = self.suggestedRoutes[indexPath.row]
				cell.textLabel?.text = title
				cell.accessoryType = .disclosureIndicator
				cell.detailTextLabel!.text = "共\(route.links.count)站，轉\(route.transitions.count - 1)次"
			case 3:
				cell.selectionStyle = .none
				cell.accessoryType = .none
				cell.textLabel?.text = ["🚉 單程票", " 🚉 悠遊卡", "👴🏻 敬老、愛心卡", "⏰ 官方說的時間"][indexPath.row]
				row: switch indexPath.row {
				case 0:
					cell.detailTextLabel!.text = onewayFare != nil ? formatter.string(from: NSNumber(value: Int(onewayFare!))) : ""
				case 1:
					cell.detailTextLabel!.text = easycardFare != nil ? formatter.string(from: NSNumber(value: Int(easycardFare!))) : ""
				case 2:
					cell.detailTextLabel!.text = easycardFare != nil ? formatter.string(from: NSNumber(value: Int(reducedFare!))) : ""
				case 3:
					cell.detailTextLabel!.text = time != nil ? "\(time!) 分" : ""
				default:
					break
				}
			default:
				break
			}
		}
		return cell!
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath as IndexPath, animated: true)

		func presentViewController(vc: UIViewController) {
			let nav = UINavigationController(rootViewController: vc)
			nav.preferredContentSize = CGSize(width: 320, height: 600)
			nav.modalPresentationStyle = .popover
			let cell = tableView.cellForRow(at: indexPath as IndexPath)
			nav.popoverPresentationController!.sourceView = cell!
			nav.popoverPresentationController!.sourceRect = cell!.bounds
			self.present(nav, animated: true, completion: nil)
		}

		switch indexPath.section {
		case 0:
			presentViewController(vc: fromPicker)
		case 1:
			presentViewController(vc: toPicker)
		case 2:
			let vc = MRTRouteViewController()
			let (title, route) = self.suggestedRoutes[indexPath.row]
			vc.title = title
			vc.route = route
			let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
			appDelegate.splitViewController!.showDetailViewController(UINavigationController(rootViewController: vc), sender: self)
		default:
			break
		}
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section < 2 {
			return ["請選擇起點", "請選擇終點"][section]
		}
		return nil
	}

}

extension MRTRootTableViewController: MRTExitPickerDelegate {

	func announcementDidFinish(notification: NSNotification) {
		let cell = self.tableView.cellForRow(at: NSIndexPath(row: 0, section: 2) as IndexPath)
		if let cell = cell {
			UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, cell.contentView)
		}
	}

	func exitPicker(picker: MRTExitPicker, didSelectStationName name: String) {
		if picker == self.fromPicker {
			self.from = name
		} else if picker == self.toPicker {
			self.to = name
		}

		if self.from == nil || self.to == nil {
			self.dismiss(animated: true, completion: {
				self.tableView.reloadData()
			})
			return
		}

		self.dismiss(animated: true, completion: {
			self.suggestedRoutes.removeAll(keepingCapacity: false)
			self.tableView.reloadData()
			guard let routes = MRTMap.sharedMap.findRoutes(fromID: self.from!, toID: self.to!), routes.count > 0 else {
				return
			}

			let routesSortedByExitcount = routes.sorted() {
				if $0.links.count == $1.links.count {
					return $0.transitions.count < $1.transitions.count
				}
				return $0.links.count < $1.links.count
			}

			let routesSortedByTransitionCount = routes.sorted() {
				if $0.transitions.count == $1.transitions.count {
					return $0.links.count < $1.links.count
				}
				return $0.transitions.count < $1.transitions.count
			}
			let routeWithFewestExits = routesSortedByExitcount[0]
			let routeWithFewestTransitions = routesSortedByTransitionCount[0]
			var routeToSpeakOut: MRTRoute?

			if (routeWithFewestExits === routeWithFewestTransitions) {
				self.suggestedRoutes.append(("建議路線", routeWithFewestExits))
				routeToSpeakOut = routeWithFewestExits
			} else if (routeWithFewestExits.links.count == routeWithFewestTransitions.links.count) {
				self.suggestedRoutes.append(("建議路線", routeWithFewestTransitions))
				routeToSpeakOut = routeWithFewestTransitions
			} else {
				self.suggestedRoutes.append(("車站最少路線", routeWithFewestExits))
				self.suggestedRoutes.append(("轉乘最少路線", routeWithFewestTransitions))
			}

			if routesSortedByExitcount.count > 1 {
				let crazyRoute = routesSortedByExitcount.last!
				self.suggestedRoutes.append(("最遠路線…", crazyRoute))
				let mostTransitionRoute = routesSortedByTransitionCount.last!
				if crazyRoute !== mostTransitionRoute {
					self.suggestedRoutes.append(("轉乘最多次…", mostTransitionRoute))
				}
			}

			var fares = MRTPriceDatabase.shared.price(fromStationName: self.from!, toStationName: self.to!)
			let (v1, v2, v3, v4) = fares[0]
			self.onewayFare = v1
			self.easycardFare = v2
			self.reducedFare = v3
			self.time = v4
			self.tableView.reloadData()

			DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
				if self.suggestedRoutes.count == 0 {
					return
				}
				let message = routeToSpeakOut != nil ?
						"找到了建議路線，共 \(routeToSpeakOut!.links.count) 站，轉乘 \(routeToSpeakOut!.transitions.count - 1)  次" :
						"我們找到了車站最少與轉乘最少兩條路線"
				UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, message)
			})
		})
	}
}
