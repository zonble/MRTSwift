import Foundation

public class MRTPriceDatabase {
	public static let sharedDatabase = MRTPriceDatabase()
	var db: OpaquePointer? = nil

	init() {
		let bundle = Bundle(for: MRTPriceDatabase.self)
		let path = bundle.path(forResource: "data", ofType: "sqlite")
		let cpath = path!.cString(using: String.Encoding.utf8)
		let error = sqlite3_open(cpath!, &db)
		if error != SQLITE_OK {
			// Open failed, close DB and fail
			print("SQLiteDB - failed to open DB!")
			sqlite3_close(db)
		}
	}

	deinit {
		if db != nil {
			sqlite3_close(db)
		}
	}

	public func price(fromStationName: String, toStationName: String) -> [(Int32, Int32, Int32, Int32)] {
		let sql = "select * from data where from_station=\"\(fromStationName)\" and to_station=\"\(toStationName)\";"
		var stmt: OpaquePointer? = nil
		let cSql = sql.cString(using: String.Encoding.utf8)
		let result = sqlite3_prepare_v2(self.db, cSql!, -1, &stmt, nil)
		var rows = [(Int32, Int32, Int32, Int32)]()
		if result == SQLITE_OK {
			var stepResult = sqlite3_step(stmt)
			while stepResult == SQLITE_ROW {
				let oneway = sqlite3_column_int(stmt, 2)
				let easycard = sqlite3_column_int(stmt, 3)
				let reducedFare = sqlite3_column_int(stmt, 4)
				let time = sqlite3_column_int(stmt, 5)
				rows.append((oneway, easycard, reducedFare, time))
				stepResult = sqlite3_step(stmt)
			}
		}
		sqlite3_finalize(stmt)
		return rows
	}


}
