import Foundation

public class MRTRoute {
	public private(set) var from: MRTExit
	public private(set) var links: [MRTLink]
	public private(set) var transitions = [[(String, MRTExit, MRTExit)]]()

	init(from: MRTExit, links: [MRTLink]) {
		self.from = from
		self.links = links

		var transitionsArray = [[(String, MRTExit, MRTExit)]]()
		var currentSection = [(String, MRTExit, MRTExit)]()
		var lastLineID = links[0].lineID
		currentSection.append((self.links[0].lineID, from, self.links[0].to))
		for i in 1..<self.links.count {
			let link = self.links[i]
			if link.lineID != lastLineID {
				var connected = false
				switch link.lineID {
				case "4":
					connected = (lastLineID == "4A" || lastLineID == "4B")
				case "4A":
					connected = lastLineID == "4"
				case "4B":
					connected = lastLineID == "4"
				default:
					break
				}
				if (!connected) {
					transitionsArray.append(currentSection)
					currentSection = [(String, MRTExit, MRTExit)]()
				}
			}
			currentSection.append((link.lineID, links[i - 1].to, link.to))
			lastLineID = link.lineID
		}
		transitionsArray.append(currentSection)
		self.transitions = transitionsArray
	}
}
