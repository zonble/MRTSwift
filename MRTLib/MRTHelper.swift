import Foundation

var MRTLineNameDictionary = [
	"1": "文湖線",
	"2":"淡水信義線",
	"3": "松山信義線",
	"4": "中和新蘆線",
	"5": "板南線"]

func MRTLineName(lineID :String) -> String? {
	return MRTLineNameDictionary[lineID]
}
