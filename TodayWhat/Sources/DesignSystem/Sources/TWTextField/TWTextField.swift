import SwiftUI
import TWColor

public struct TWTextField: View {
    @Binding private var text: String
    private var placeholder: String
    private var onCommit: () -> Void
    @FocusState private var isFocused: Bool

    public init(
        _ placeholder: String = "",
        text: Binding<String>,
        onCommit: @escaping () -> Void = {}
    ) {
        _text = text
        self.placeholder = placeholder
        self.onCommit = onCommit
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            TextField("", text: $text)
                .font(.system(size: 16))
                .foregroundColor(.extraPrimary)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.veryLightGray)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isFocused ? Color.extraPrimary : .lightGray, lineWidth: 1)
                }
                .focused($isFocused)
                .onSubmit(onCommit)
                .zIndex(1)

            Group {
                if isFocused || !text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 12))
                        .foregroundColor(.extraGray)
                        .offset(y: -35)
                        .transition(.offset(y: 20))
                        .zIndex(0)
                } else {
                    Text(placeholder)
                        .font(.system(size: 16))
                        .foregroundColor(.extraGray)
                        .padding()
                        .onTapGesture {
                            isFocused = true
                        }
                        .zIndex(1)
                }
            }
            .animation(.default, value: isFocused)

            
            HStack {
                Spacer()
                
                Button {
                    withAnimation {
                        text = ""
                    }
                } label: {
                    if isFocused && !text.isEmpty {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.extraGray)
                            .frame(width: 28, height: 28)
                    } else {
                        EmptyView()
                    }
                }
            }
            .zIndex(2)
            .padding(.trailing)
            .animation(.default, value: text)
            .animation(.default, value: isFocused)
        }
    }
}
