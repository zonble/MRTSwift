import Foundation
#if os(OSX)
import AppKit
#else
import UIKit
#endif

let MRTLineNameDictionary = [
	"1": "文湖線",
	"2": "淡水信義線",
	"3": "松山新店線",
	"4": "中和線",
	"4A": "新莊線",
	"4B": "蘆洲線",
	"5": "板南線"]

#if os(OSX)
let MRTLineColorDictionary = [
	"1": NSColor.systemBrown,
	"2": NSColor.systemRed,
	"3": NSColor.systemGreen,
	"4": NSColor.systemYellow,
	"4A": NSColor.systemYellow,
	"4B": NSColor.systemYellow,
	"5": NSColor.systemBlue]
#else
let MRTLineColorDictionary = [
	"1": UIColor.systemBrown,
	"2": UIColor.systemRed,
	"3": UIColor.systemGreen,
	"4": UIColor.systemYellow,
	"4A": UIColor.systemYellow,
	"4B": UIColor.systemYellow,
	"5": UIColor.systemBlue]
#endif

public func MRTLineName(lineID: String) -> String? {
	return MRTLineNameDictionary[lineID]
}

#if os(OSX)
public func MRTLineColor(lineID: String) -> NSColor? {
	return MRTLineColorDictionary[lineID]
}
#else
public func MRTLineColor(lineID: String) -> UIColor? {
	return MRTLineColorDictionary[lineID]
}
#endif
