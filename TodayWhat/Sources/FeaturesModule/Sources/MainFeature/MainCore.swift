import ComposableArchitecture

public struct MainCore: ReducerProtocol {
    public init() {}
    public struct State: Equatable {
        
        public init() {}
    }

    public enum Action: Equatable {
        
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            
            default:
                return .none
            }
        }
    }
}