import Foundation

class MRTExit : Equatable {
	var name :String
	var links = [MRTLink]()

	init(name :String) {
		self.name = name
	}

	func addLink(lineID :String, to :MRTExit) {
		self.links.append(MRTLink(lineID: lineID, to: to))
	}
}

func ==(lhs: MRTExit, rhs: MRTExit) -> Bool {
	return lhs === rhs
}
