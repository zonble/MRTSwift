import Foundation

public class MRTExit: Equatable {
	public var name: String
	public var links = [MRTLink]()
	public var address: String?
	public var logitude: Float?
	public var latitude: Float?

	init(name: String) {
		self.name = name
	}

	func addLink(lineID: String, to: MRTExit) {
		self.links.append(MRTLink(lineID: lineID, to: to))
	}
}

public func ==(lhs: MRTExit, rhs: MRTExit) -> Bool {
	return lhs === rhs
}
