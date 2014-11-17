import UIKit
import XCTest

class MRTTransitSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

	func testPriceDatabase() {
		self.measureBlock { () -> Void in
			let tracks = MRTMap.sharedMap.tracks
			var names = [String]()
			for trackID in tracks.keys {
				let trackStationNames = tracks[trackID]
				names += trackStationNames!
			}
			for name1 in names {
				for name2 in names {
					if name1 == name2 {
						continue
					}
					let a = MRTPriceDatabase.sharedDatabase.price(name1, toStationName: name2)
					assert(a.count == 1, "Must have a result")
				}
			}
		}
	}

}
