import Foundation

public struct Meal: Equatable, Hashable {
    public let breakfast: SubMeal
    public let lunch: SubMeal
    public let dinner: SubMeal

    public init(breakfast: SubMeal, lunch: SubMeal, dinner: SubMeal) {
        self.breakfast = breakfast
        self.lunch = lunch
        self.dinner = dinner
    }

    public struct SubMeal: Equatable, Hashable {
        public let meals: [String]
        public let cal: Int

        public init(meals: [String], cal: Int) {
            self.meals = meals
            self.cal = cal
        }
    }
}