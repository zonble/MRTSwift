import Foundation

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
	"1": NSColor(hue: 0.1, saturation: 08, brightness: 0.71, alpha: 0.7),
	"2": NSColor(hue: 0.97, saturation: 1.0, brightness: 0.85, alpha: 0.7),
	"3": NSColor(hue: 0.42, saturation: 0.84, brightness: 0.42, alpha: 0.7),
	"4": NSColor(hue: 0.12, saturation: 0.75, brightness: 0.91, alpha: 0.7),
	"4A": NSColor(hue: 0.12, saturation: 0.75, brightness: 0.91, alpha: 0.7),
	"4B": NSColor(hue: 0.12, saturation: 0.75, brightness: 0.91, alpha: 0.7),
	"5": NSColor(hue: 0.58, saturation: 0.95, brightness: 0.66, alpha: 0.7)]
#else
let MRTLineColorDictionary = [
	"1": UIColor(hue: 0.1, saturation: 08, brightness: 0.71, alpha: 0.7),
	"2": UIColor(hue: 0.97, saturation: 1.0, brightness: 0.85, alpha: 0.7),
	"3": UIColor(hue: 0.42, saturation: 0.84, brightness: 0.42, alpha: 0.7),
	"4": UIColor(hue: 0.12, saturation: 0.75, brightness: 0.91, alpha: 0.7),
	"4A": UIColor(hue: 0.12, saturation: 0.75, brightness: 0.91, alpha: 0.7),
	"4B": UIColor(hue: 0.12, saturation: 0.75, brightness: 0.91, alpha: 0.7),
	"5": UIColor(hue: 0.58, saturation: 0.95, brightness: 0.66, alpha: 0.7)]
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
