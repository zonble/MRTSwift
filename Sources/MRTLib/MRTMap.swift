import Foundation

public class MRTMap {
	public static let sharedMap = MRTMap()

	public private(set) var exits: [String: MRTExit]!
	public private(set) var lines: [String: [String]]!

	init() {
		self.loadData()
	}

	private func loadData() {

		let addressFilePath = Bundle(for: MRTMap.self).path(forResource: "address", ofType: "txt")
		if addressFilePath == nil {
			return
		}
		var addressData: String!
		do {
			addressData = try String(contentsOfFile: addressFilePath!, encoding: .utf8)
		} catch {
			print("\(error)")
			return
		}

		let lineDataFilepath = Bundle(for: MRTMap.self).path(forResource: "data", ofType: "txt")
		if lineDataFilepath == nil {
			return
		}
		let lineData = try! String(contentsOfFile: lineDataFilepath!, encoding: .utf8)

		var mapDict = [String: MRTExit]()
		var linesDict = [String: [String]]()

		for lines in addressData.components(separatedBy: "\n") {
			let components = lines.components(separatedBy: ",")
			if components.count != 4 {
				continue
			}
			let stationName = components[0] 
			let address = components[1] 
			let logitude = components[2] 
			let latitude = components[3] 

			if mapDict[stationName] === nil {
				let exit = MRTExit(name: stationName)
				exit.address = address.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).replacingOccurrences(of: "<br>", with: "\n")
				exit.logitude = (logitude as NSString).floatValue
				exit.latitude = (latitude as NSString).floatValue
				mapDict[stationName] = exit
			}
		}

		for lines in lineData.components(separatedBy: "\n") {
			let components = lines.components(separatedBy: ",")
			if components.count != 3 {
				continue
			}
			let routeID = components[0] 
			let fromID = components[1] 
			let toID = components[2] 

			mapDict[fromID]!.addLink(lineID: routeID, to: mapDict[toID]!)
			mapDict[toID]!.addLink(lineID: routeID, to: mapDict[fromID]!)

			var line = linesDict[routeID]
			if line == nil {
				line = [String]()
				linesDict[routeID] = line
			}
			if !line!.contains(fromID) {
				line!.append(fromID)
			}
			if !line!.contains(toID) {
				line!.append(toID)
			}
			linesDict[routeID] = line
		}
		self.exits = mapDict
		self.lines = linesDict
	}

	public func findRoutes(fromID: String, toID: String) -> [MRTRoute]? {
		let fromExit = exits[fromID]
		if fromExit == nil {
			return nil
		}
		let toExit = exits[toID]
		if toExit == nil {
			return nil
		}
		if fromExit == toExit {
			return nil
		}
		return MRTRouteFinder(fromExit: fromExit!, toExit: toExit!).foundRoutes
	}
}

class MRTRouteFinder {
	var visitedLinks = [MRTLink]()
	var visitedExits = [MRTExit]()
	var foundRoutes = [MRTRoute]()
	var fromExit: MRTExit
	var toExit: MRTExit

	init(fromExit: MRTExit, toExit: MRTExit) {
		self.fromExit = fromExit
		self.toExit = toExit
		self.travelLinksForExit(exit: self.fromExit)
	}

	func travelLinksForExit(exit: MRTExit) {
		for link in exit.links {
			if link.to == toExit {
				var copy = visitedLinks
				copy.append(link)
				foundRoutes.append(MRTRoute(from: self.fromExit, links: copy))
			} else if !visitedExits.contains(link.to) {
				visitedExits.append(exit)
				visitedLinks.append(link)
				travelLinksForExit(exit: link.to)
				visitedExits.removeLast()
				visitedLinks.removeLast()
			}
		}
	}

}

