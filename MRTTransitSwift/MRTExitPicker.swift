import UIKit

protocol MRTExitPickerDelegate {
	func exitPicker(picker: ExitPicker, didSelectStationName name :String)
}

class ExitPicker :UITableViewController {
	var delegate :MRTExitPickerDelegate?
	var selectedIndexPath :NSIndexPath?

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "請選擇捷運站"
		self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		var backItem = UIBarButtonItem(title: "", style: .Bordered, target: nil, action: nil)
		self.navigationItem.backBarButtonItem = backItem
	}

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 7
	}

	func lineIDWithSection(section: Int) -> String? {
		return ["1", "2", "3", "4", "4A", "4B", "5"][section]
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let lineID = lineIDWithSection(section)!
		let exitNames = MRTMap.sharedMap.lines[lineID]!
		return exitNames.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
		cell.textLabel?.textColor = UIColor.blackColor()
		cell.textLabel?.textAlignment = .Left
		let lineID = lineIDWithSection(indexPath.section)!
		let exitNames = MRTMap.sharedMap.lines[lineID]!
		cell.textLabel?.text = exitNames[indexPath.row]
		cell.accessoryType = self.selectedIndexPath? == indexPath ? .Checkmark : .None
		return cell
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		self.selectedIndexPath = indexPath
		self.tableView.reloadData()
		let lineID = lineIDWithSection(indexPath.section)!
		let exitNames = MRTMap.sharedMap.lines[lineID]!
		self.delegate?.exitPicker(self, didSelectStationName: exitNames[indexPath.row])
	}

	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		let lineID = lineIDWithSection(section)!
		return MRTLineName(lineID)
	}

	override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
		return ["文湖", "淡水", "松山", "中和", "新莊", "蘆洲", "板南"]
	}

}