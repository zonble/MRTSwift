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

	private var exits :[String: MRTExit]!
	var tracks: [String: [String]]!

	init() {
		self.loadData()
	}

	private func loadData() {
		let path = NSBundle(forClass: MRTMap.self).pathForResource("data", ofType: "txt")
		if path == nil { return }
		let str = NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)
		if str == nil { return }

		var mapDict = [String: MRTExit]()
		var tracksDict = [String: [String]]()

		for lines in str!.componentsSeparatedByString("\n") {
			let components = lines.componentsSeparatedByString(",")
			if components.count != 3 { continue }
			let routeID = components[0] as String
			let fromID = components[1] as String
			let toID = components[2] as String
			if mapDict[fromID] === nil {
				mapDict[fromID] = MRTExit(name: fromID)
			}
			if mapDict[toID] === nil {
				mapDict[toID] = MRTExit(name: toID)
			}
			mapDict[fromID]!.addLink(routeID, to: mapDict[toID]!)
			mapDict[toID]!.addLink(routeID, to: mapDict[fromID]!)

			var track = tracksDict[routeID]
			if track == nil {
				track = [String]()
				tracksDict[routeID] = track
			}
			if !contains(track!, fromID) { track!.append(fromID) }
			if !contains(track!, toID) { track!.append(toID) }
			 tracksDict[routeID] = track
		}
		self.exits = mapDict
		self.tracks = tracksDict
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

