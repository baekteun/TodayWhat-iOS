import Dependencies
import Foundation
import NeisClient
import Entity
import ResponseDTO
import UserDefaultsClient
import DateUtil

public struct MealClient: Sendable {
    public var fetchMeal: @Sendable (_ date: Date) async throws -> Meal
}

extension MealClient: DependencyKey {
    public static var liveValue: MealClient = MealClient(
        fetchMeal: { date in
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
                let orgCode = userDefaultsClient.getValue(key: .orgCode, type: String.self),
                let code = userDefaultsClient.getValue(key: .schoolCode, type: String.self)
            else {
                return Meal(
                    breakfast: .init(meals: [], cal: 0),
                    lunch: .init(meals: [], cal: 0),
                    dinner: .init(meals: [], cal: 0)
                )
            }

            @Dependency(\.neisClient) var neisClient

            let month = date.month < 10 ? "0\(date.month)" : "\(date.month)"
            let day = date.day < 10 ? "0\(date.day)" : "\(date.day)"
            let reqDate = "\(date.year)\(month)\(day)"

            let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
            let response = try await neisClient.fetchDataOnNeis(
                "mealServiceDietInfo",
                queryItem: [
                    .init(name: "KEY", value: key),
                    .init(name: "Type", value: "json"),
                    .init(name: "pIndex", value: "1"),
                    .init(name: "pSize", value: "10"),
                    .init(name: "ATPT_OFCDC_SC_CODE", value: orgCode),
                    .init(name: "SD_SCHUL_CODE", value: code),
                    .init(name: "MLSV_FROM_YMD", value: reqDate),
                    .init(name: "MLSV_TO_YMD", value: reqDate)
                ],
                key: "mealServiceDietInfo",
                type: [SingleMealResponseDTO].self
            )

            let breakfast = response.first { $0.type == .breakfast }
                .map { dto in
                    Meal.SubMeal(
                        meals: dto.info.replacingOccurrences(of: " ", with: "").components(separatedBy: "<br/>"),
                        cal: Double(dto.calInfo.components(separatedBy: " ").first ?? "0") ?? 0
                    )
                }
            let lunch = response.first { $0.type == .lunch }
                .map { dto in
                    Meal.SubMeal(
                        meals: dto.info.replacingOccurrences(of: " ", with: "").components(separatedBy: "<br/>"),
                        cal: Double(dto.calInfo.components(separatedBy: " ").first ?? "0") ?? 0
                    )
                }
            let dinner = response.first { $0.type == .dinner }
                .map { dto in
                    Meal.SubMeal(
                        meals: dto.info.replacingOccurrences(of: " ", with: "").components(separatedBy: "<br/>"),
                        cal: Double(dto.calInfo.components(separatedBy: " ").first ?? "0") ?? 0
                    )
                }
            guard
                let breakfast,
                let lunch,
                let dinner
            else {
                return Meal(
                    breakfast: .init(meals: [], cal: 0),
                    lunch: .init(meals: [], cal: 0),
                    dinner: .init(meals: [], cal: 0)
                )
            }

            return Meal(breakfast: breakfast, lunch: lunch, dinner: dinner)
        }
    )
}

extension DependencyValues {
    public var mealClient: MealClient {
        get { self[MealClient.self] }
        set { self[MealClient.self] = newValue }
    }
}
