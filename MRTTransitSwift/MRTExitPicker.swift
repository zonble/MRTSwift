import UIKit

protocol MRTExitPickerDelegate {
	func exitPicker(picker: ExitPicker, didSelectStationName name: String)
}

class ExitPicker: UITableViewController {
	var delegate: MRTExitPickerDelegate?
	var selectedIndexPath: IndexPath?

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "請選擇捷運站"
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		let backItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		self.navigationItem.backBarButtonItem = backItem
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 7
	}

	func lineIDWithSection(section: Int) -> String? {
		return ["1", "2", "3", "4", "4A", "4B", "5"][section]
	}


	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let lineID = lineIDWithSection(section: section)!
		let exitNames = MRTMap.sharedMap.lines[lineID]!
		return exitNames.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
		cell?.textLabel?.textColor = UIColor.black
		cell?.textLabel?.textAlignment = .left
		let lineID = lineIDWithSection(section: indexPath.section)!
		let exitNames = MRTMap.sharedMap.lines[lineID]!
		cell?.textLabel?.text = exitNames[indexPath.row]
		cell?.accessoryType = self.selectedIndexPath == indexPath ? .checkmark : .none
		return cell!
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath as IndexPath, animated: true)
		self.selectedIndexPath = indexPath
		self.tableView.reloadData()
		let lineID = lineIDWithSection(section: indexPath.section)!
		let exitNames = MRTMap.sharedMap.lines[lineID]!
		self.delegate?.exitPicker(picker: self, didSelectStationName: exitNames[indexPath.row])
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let lineID = lineIDWithSection(section: section)!
		return MRTLineName(lineID: lineID)
	}

	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return ["文湖", "淡水", "松山", "中和", "新莊", "蘆洲", "板南"]
	}

}
