import UIKit

protocol ExitPickerDelegate {
	func exitPicker(picker: ExitPicker, didSelectStationName name :String)
}

class ExitPicker :UITableViewController {
	var delegate :ExitPickerDelegate?
	var selectedIndexPath :NSIndexPath?

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "請選擇捷運站"
		self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		var backItem = UIBarButtonItem(title: "", style: .Bordered, target: nil, action: nil)
		self.navigationItem.backBarButtonItem = backItem
	}

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 5
	}
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let lineID = "\(section + 1)"
		let exitNames = MRTMap.sharedMap.tracks[lineID]!
		return exitNames.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
		cell.textLabel.textColor = UIColor.blackColor()
		cell.textLabel.textAlignment = .Left
		let lineID = "\(indexPath.section + 1)"
		let exitNames = MRTMap.sharedMap.tracks[lineID]!
		cell.textLabel.text = exitNames[indexPath.row]
		cell.accessoryType = self.selectedIndexPath? == indexPath ? .Checkmark : .None
		return cell
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		self.selectedIndexPath = indexPath
		self.tableView.reloadData()
		let lineID = "\(indexPath.section + 1)"
		let exitNames = MRTMap.sharedMap.tracks[lineID]!
		self.delegate?.exitPicker(self, didSelectStationName: exitNames[indexPath.row])
	}

	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return MRTLineName("\(section + 1)")
	}

}