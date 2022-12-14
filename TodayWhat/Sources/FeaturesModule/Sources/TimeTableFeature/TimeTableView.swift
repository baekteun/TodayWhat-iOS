import ComposableArchitecture
import Entity
import SwiftUI
import TWColor

public struct TimeTableView: View {
    let store: StoreOf<TimeTableCore>
    @ObservedObject var viewStore: ViewStoreOf<TimeTableCore>
    
    public init(store: StoreOf<TimeTableCore>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 }, send: { _ in .onAppear })
    }

    public var body: some View {
        ScrollView {
            if viewStore.timeTableList.isEmpty && !viewStore.isLoading && !viewStore.isError {
                Text("등록된 정보를 찾지 못했어요 😥")
                    .padding(.top, 16)
            }

            if viewStore.isError {
                Text("시간표를 가져오는 중 오류가 발생했어요 😥")
                    .foregroundColor(.red)
                    .padding(.top, 16)
            }

            ZStack {
                if viewStore.isLoading {
                    ProgressView()
                        .progressViewStyle(.automatic)
                        .padding(.top, 16)
                }

                LazyVStack(spacing: 8) {
                    Spacer()
                        .frame(height: 16)

                    ForEach(viewStore.timeTableList, id: \.self) { timeTable in
                        timeTableRow(timeTable: timeTable)
                            .padding(.horizontal, 16)
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .onAppear {
            viewStore.send(.onAppear, animation: .default)
        }
        .refreshable {
            viewStore.send(.refresh, animation: .default)
        }
    }

    @ViewBuilder
    private func timeTableRow(timeTable: TimeTable) -> some View {
        HStack(spacing: 8) {
            Text("\(timeTable.perio)교시")
                .font(.system(size: 12))
                .foregroundColor(.darkGray)

            Divider()
                .foregroundColor(.lightGray)
                .frame(height: 18)

            Text(timeTable.content)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.extraPrimary)
                .padding(.leading, 4)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background {
            Color.veryLightGray
        }
        .cornerRadius(4)
    }
}
