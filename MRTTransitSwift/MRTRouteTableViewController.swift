import UIKit

class MRTRouteTableViewController :UITableViewController {
	var route: MRTRoute? {
		didSet {
			self.tableView.reloadData()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "台北捷運轉乘"
	}

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return self.route?.transitions.count ?? 1
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let route = self.route {
			return route.transitions[section].count
		}
		return 0
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell :UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
		if cell == nil {
			cell = UITableViewCell(style: .Value1, reuseIdentifier: "Cell")
		}
		if let cell = cell {
			cell.textLabel.textColor = UIColor.blackColor()
			cell.textLabel.textAlignment = .Left
			cell.selectionStyle = .None
			if let route = self.route {
				let routeSection = route.transitions[indexPath.section]
				let (lineID, from, to) = routeSection[indexPath.row]
				cell.textLabel.text = "\(from.name) - \(to.name)"
				cell.detailTextLabel!.text = MRTLineName(lineID)
			}
		}
		return cell!
	}

	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			if let route = self.route {
				return "共 \(route.links.count) 站，轉乘 \(route.transitions.count - 1)  次"
			}
		}
		return nil
	}

}

