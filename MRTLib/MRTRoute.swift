import Foundation

class MRTRoute {
	var from :MRTExit
	var links :[MRTLink]
	var transitions = [[(String, MRTExit, MRTExit)]]()

	init(from :MRTExit, links:[MRTLink]) {
		self.from = from
		self.links = links

		var transitionsArray = [[(String, MRTExit, MRTExit)]]()
		var currentSection = [(String, MRTExit, MRTExit)]()
		var lastLineID = links[0].lineID
		currentSection.append((self.links[0].lineID, from, self.links[0].to))
		for i in 1..<self.links.count {
			let link = self.links[i]
			if link.lineID != lastLineID {
				transitionsArray.append(currentSection)
				currentSection = [(String, MRTExit, MRTExit)]()
			}
			currentSection.append((link.lineID, links[i - 1].to, link.to))
			lastLineID = link.lineID
		}
		transitionsArray.append(currentSection)
		self.transitions = transitionsArray
	}
}
