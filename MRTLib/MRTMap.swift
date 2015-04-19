import Foundation

class MRTMap {
	class var sharedMap :MRTMap {
		get {
			struct _internal {
				static let _sharedMap = MRTMap()
			}
			return _internal._sharedMap
		}
	}

	var exits :[String: MRTExit]!
	var lines: [String: [String]]!

	init() {
		self.loadData()
	}

	private func loadData() {

		let addressFilePath = NSBundle(forClass: MRTMap.self).pathForResource("address", ofType: "txt")
		if addressFilePath == nil { return }
		let addressData = NSString(contentsOfFile: addressFilePath!, encoding: NSUTF8StringEncoding, error: nil)
		if addressData == nil { return }

		let lineDataFilepath = NSBundle(forClass: MRTMap.self).pathForResource("data", ofType: "txt")
		if lineDataFilepath == nil { return }
		let lineData = NSString(contentsOfFile: lineDataFilepath!, encoding: NSUTF8StringEncoding, error: nil)
		if lineData == nil { return }

		var mapDict = [String: MRTExit]()
		var linesDict = [String: [String]]()

		for lines in addressData!.componentsSeparatedByString("\n") {
			let components = lines.componentsSeparatedByString(",")
			if components.count != 4 { continue }
			let stationName = components[0] as! String
			let address = components[1] as! String
			let logitude = components[2] as! String
			let latitude = components[3] as! String

			if mapDict[stationName] === nil {
				let exit = MRTExit(name: stationName)
				exit.address = address
				exit.logitude = (logitude as NSString).floatValue
				exit.latitude = (latitude as NSString).floatValue
				mapDict[stationName] = exit
			}
		}

		for lines in lineData!.componentsSeparatedByString("\n") {
			let components = lines.componentsSeparatedByString(",")
			if components.count != 3 { continue }
			let routeID = components[0] as! String
			let fromID = components[1] as! String
			let toID = components[2] as! String

			mapDict[fromID]!.addLink(routeID, to: mapDict[toID]!)
			mapDict[toID]!.addLink(routeID, to: mapDict[fromID]!)

			var line = linesDict[routeID]
			if line == nil {
				line = [String]()
				linesDict[routeID] = line
			}
			if !contains(line!, fromID) { line!.append(fromID) }
			if !contains(line!, toID) { line!.append(toID) }
			 linesDict[routeID] = line
		}
		self.exits = mapDict
		self.lines = linesDict
	}

	func findRoutes(fromID :String, toID :String) -> [MRTRoute]? {
		var fromExit = exits[fromID]
		if fromExit == nil { return nil }
		var toExit = exits[toID]
		if toExit == nil { return nil }
		if fromExit == toExit { return nil }
		return MRTRouteFinder(fromExit: fromExit!, toExit: toExit!).foundRoutes
	}
}

class MRTRouteFinder {
	var visitedLinks = [MRTLink]()
	var visitedExits = [MRTExit]()
	var foundRoutes = [MRTRoute]()
	var fromExit :MRTExit
	var toExit :MRTExit

	init(fromExit: MRTExit, toExit :MRTExit) {
		self.fromExit = fromExit
		self.toExit = toExit
		self.travelLinksForExit(self.fromExit)
	}

	func travelLinksForExit(exit :MRTExit) {
		for link in exit.links {
			if link.to == toExit {
				var copy = visitedLinks
				copy.append(link)
				foundRoutes.append(MRTRoute(from: self.fromExit, links: copy))
			}
			else if !contains(visitedExits, link.to) {
				visitedExits.append(exit)
				visitedLinks.append(link)
				travelLinksForExit(link.to)
				visitedExits.removeLast()
				visitedLinks.removeLast()
			}
		}
	}

}

