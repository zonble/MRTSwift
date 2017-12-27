import Foundation

let MRTLineNameDictionary = [
	"1": "文湖線",
	"2": "淡水信義線",
	"3": "松山新店線",
	"4": "中和線",
	"4A": "新莊線",
	"4B": "蘆洲線",
	"5": "板南線"]

public func MRTLineName(lineID: String) -> String? {
	return MRTLineNameDictionary[lineID]
}
