import Dependencies
import Foundation
import NeisClient
import Entity
import ResponseDTO
import UserDefaultsClient
import DateUtil
import EnumUtil
import ConstantUtil

public struct TimeTableClient: Sendable {
    public var fetchTimeTable: @Sendable (_ date: Date) async throws -> [TimeTable]
}

extension TimeTableClient: DependencyKey {
    public static var liveValue: TimeTableClient = TimeTableClient(
        fetchTimeTable: { date in
            var date = date
            @Dependency(\.userDefaultsClient) var userDefaultsClient: UserDefaultsClient

            if userDefaultsClient.getValue(key: .isSkipWeekend, type: Bool.self) == true {
                if date.weekday == 7 {
                    date = date.adding(by: .day, value: 2)
                } else if date.weekday == 1 {
                    date = date.adding(by: .day, value: 1)
                }
            }

            guard
                let typeRaw = userDefaultsClient.getValue(key: .schoolType, type: String.self),
                let type = SchoolType(rawValue: typeRaw),
                let code = userDefaultsClient.getValue(key: .schoolCode, type: String.self),
                let orgCode = userDefaultsClient.getValue(key: .orgCode, type: String.self),
                let grade = userDefaultsClient.getValue(key: .grade, type: Int.self),
                let `class` = userDefaultsClient.getValue(key: .class, type: Int.self)
            else {
                return []
            }
            let major = userDefaultsClient.getValue(key: .major, type: String.self)

            let month = date.month < 10 ? "0\(date.month)" : "\(date.month)"
            let day = date.day < 10 ? "0\(date.day)" : "\(date.day)"
            let reqDate = "\(date.year)\(month)\(day)"

            @Dependency(\.neisClient) var neisClient

            let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
            let response: [SingleTimeTableResponseDTO]
            do {
                response = try await neisClient.fetchDataOnNeis(
                    type.toSubURL(),
                    queryItem: [
                        .init(name: "KEY", value: key),
                        .init(name: "Type", value: "json"),
                        .init(name: "pIndex", value: "1"),
                        .init(name: "pSize", value: "30"),
                        .init(name: "ATPT_OFCDC_SC_CODE", value: orgCode),
                        .init(name: "SD_SCHUL_CODE", value: code),
                        .init(name: "DDDEP_NM", value: major),
                        .init(name: "GRADE", value: "\(grade)"),
                        .init(name: "CLASS_NM", value: "\(`class`)"),
                        .init(name: "TI_FROM_YMD", value: reqDate),
                        .init(name: "TI_TO_YMD", value: reqDate)
                    ],
                    key: type.toSubURL(),
                    type: [SingleTimeTableResponseDTO].self
                )
            } catch {
                response = try await neisClient.fetchDataOnNeis(
                    type.toSubURL(),
                    queryItem: [
                        .init(name: "KEY", value: key),
                        .init(name: "Type", value: "json"),
                        .init(name: "pIndex", value: "1"),
                        .init(name: "pSize", value: "30"),
                        .init(name: "ATPT_OFCDC_SC_CODE", value: orgCode),
                        .init(name: "SD_SCHUL_CODE", value: code),
                        .init(name: "GRADE", value: "\(grade)"),
                        .init(name: "CLASS_NM", value: "\(`class`)"),
                        .init(name: "TI_FROM_YMD", value: reqDate),
                        .init(name: "TI_TO_YMD", value: reqDate)
                    ],
                    key: type.toSubURL(),
                    type: [SingleTimeTableResponseDTO].self
                )
            }
            
            return response.map { $0.toDomain() }
        }
    )
}

extension TimeTableClient: TestDependencyKey {
    public static var testValue: TimeTableClient = TimeTableClient(
        fetchTimeTable: { _ in [] }
    )
}

extension DependencyValues {
    public var timeTableClient: TimeTableClient {
        get { self[TimeTableClient.self] }
        set { self[TimeTableClient.self] = newValue }
    }
}
