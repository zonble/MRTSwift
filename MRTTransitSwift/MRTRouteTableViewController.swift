import UIKit
import MRTLib

class MRTRouteTableViewController: UITableViewController {
	var route: MRTRoute? {
		didSet {
			self.tableView.reloadData()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "台北捷運轉乘"
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return self.route?.transitions.count ?? 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.route?.transitions[section].count ?? 0
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "Cell")
		if cell == nil {
			cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
		}
		if let cell = cell {
			cell.textLabel?.textColor = UIColor.label
			cell.textLabel?.textAlignment = .left
			cell.selectionStyle = .none
			if let route = self.route {
				let routeSection = route.transitions[indexPath.section]
				let (lineID, from, to) = routeSection[indexPath.row]
				cell.textLabel?.text = indexPath.row == 0 ? "\(from.name) - \(to.name)" : to.name
				cell.detailTextLabel?.text = MRTLineName(lineID: lineID)
				cell.detailTextLabel?.textColor =  MRTLineColor(lineID: lineID)
			}
		}
		return cell!
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			if let route = self.route {
				return "共 \(route.links.count) 站，轉乘 \(route.transitions.count - 1)  次"
			}
		}
		return nil
	}

}

