import Foundation

class MRTLink {
	var lineID: String
	var to: MRTExit

	init(lineID: String, to: MRTExit) {
		self.lineID = lineID
		self.to = to
	}
}
