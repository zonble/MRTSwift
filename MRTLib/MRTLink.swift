import Foundation

public struct MRTLink {
	public private(set) var lineID: String
	public private(set) var to: MRTExit

	init(lineID: String, to: MRTExit) {
		self.lineID = lineID
		self.to = to
	}
}
