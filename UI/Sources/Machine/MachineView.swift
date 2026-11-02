import DesignSystem
import SwiftUI

struct MachineView: View {
    // Nothing connects to a machine yet.
    @State private var readings = BoilerReadings.sample(endingAt: .now)

    var body: some View {
        ScrollView {
            BoilerCard(readings: readings, state: .ready)
                .padding(.horizontal, .spacing16)
        }
        .background(.cream)
        .navigationBar(title: "Machine")
    }
}

private enum BoilerState: Equatable {
    case ready
    case heating
    case flushing
    case backflushing
    case descaling
    case updating
    case error(code: Int)
}

private struct BoilerCard: View {
    let readings: BoilerReadings
    let state: BoilerState

    @Namespace private var zoom

    var body: some View {
        VStack(spacing: 0) {
            NavigationLink {
                BoilerDetailView(readings: readings)
                    .navigationTransition(.zoom(sourceID: "boiler", in: zoom))
            } label: {
                HStack(spacing: .spacing12) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Boiler")
                            .boldSubheadlineText()
                            .foregroundStyle(.cocoa)
                        Text(readings.temperature.degrees)
                            .heavyLargeTitleText()
                            .monospacedDigit()
                            .foregroundStyle(.espresso)
                    }
                    Spacer(minLength: 0)
                    StatePill(state: state)
                }
                .padding(.horizontal, .spacing20)
                .padding(.vertical, .spacing12)
                .background(.milk)
                .matchedTransitionSource(id: "boiler", in: zoom)
            }
            .buttonStyle(.plain)
            // Above the error row, which slides out from under it.
            .zIndex(1)
            if case let .error(code) = state {
                BoilerErrorRow(code: code)
                    .transition(.move(edge: .top))
            }
        }
        .background(.milk)
        .clipShape(.rect(cornerRadius: .radius26))
        .animation(.stateChange, value: state)
    }
}

private struct StatePill: View {
    let state: BoilerState

    /// The state whose title shows; it trails `state` so the old title can fade out first.
    @State private var shown: BoilerState
    @State private var titleOpacity = 1.0

    init(state: BoilerState) {
        self.state = state
        _shown = State(initialValue: state)
    }

    var body: some View {
        // The hidden title sizes the pill, so it resizes smoothly while the visible title swaps.
        Text(state.title)
            .boldSubheadlineText()
            .hidden()
            .overlay {
                Text(shown.title)
                    .boldSubheadlineText()
                    .foregroundStyle(shown.ink)
                    .shimmering(shown.isInProgress)
                    .fixedSize()
                    .opacity(titleOpacity)
            }
            .padding(.horizontal, .spacing12)
            .padding(.vertical, .spacing8)
            .background(state.fill, in: .capsule)
            .clipShape(.capsule)
            .onChange(of: state.title) {
                withAnimation(.textFadeOut) {
                    titleOpacity = 0
                } completion: {
                    shown = state
                    withAnimation(.textFadeIn) {
                        titleOpacity = 1
                    }
                }
            }
    }
}

private struct BoilerErrorRow: View {
    let code: Int

    @State private var showsDetails = false

    var body: some View {
        HStack(spacing: .spacing12) {
            Image(systemName: "exclamationmark.triangle")
                .boldHeadlineText()
                .imageScale(.large)
                .foregroundStyle(.raspberry)
            Text(ErrorCode.title(for: code))
                .headlineText()
                .foregroundStyle(.espresso)
            Spacer(minLength: 0)
            Button("Details", systemImage: "info.circle") {
                showsDetails = true
            }
            .labelStyle(.iconOnly)
            .imageScale(.large)
            .foregroundStyle(.cocoa)
        }
        .padding(.horizontal, .spacing20)
        .padding(.vertical, .spacing12)
        .background(.blush)
        .sheet(isPresented: $showsDetails) {
            ErrorDetailsSheet(code: code)
        }
    }
}

private struct ErrorDetailsSheet: View {
    let code: Int

    @Environment(\.dismiss)
    private var dismiss

    /// The sheet's height, measured so it fits its content.
    @State private var height: CGFloat = 0

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: .spacing8) {
                Text(ErrorCode.title(for: code))
                    .boldTitle2Text()
                    .foregroundStyle(.espresso)
                Text("Error code \(code)")
                    .subheadlineText()
                    .foregroundStyle(.cocoa)
                    .padding(.bottom, .spacing32)
                // The docs have no page on error codes yet; troubleshooting is the closest.
                Link(destination: ErrorCode.documentation) {
                    Text("Open documentation")
                        .headlineText()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.primaryAction)
                .controlSize(.large)
            }
            .padding(.horizontal, .spacing20)
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom
            } action: { height = $0 }
            .frame(maxHeight: .infinity, alignment: .top)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.height(height)])
    }
}

/// Our wording for the controller's error codes; the firmware's display text only knows code 4.
private enum ErrorCode {
    static let documentation = URL(string: "https://docs.gaggimate.eu/docs/troubleshooting/")!

    static func title(for code: Int) -> String {
        switch code {
        case 1, 2, 3: "Display can't reach the controller"
        case 4: "Heater stopped for safety"
        default: "Machine error"
        }
    }
}

private extension BoilerState {
    var title: String {
        switch self {
        case .ready: "Ready"
        case .heating: "Heating"
        case .flushing: "Flushing"
        case .backflushing: "Backflushing"
        case .descaling: "Descaling"
        case .updating: "Updating"
        case .error: "Error"
        }
    }

    var fill: Color {
        switch self {
        case .ready: .seafoam
        case .heating: .peach
        case .flushing, .backflushing, .descaling, .updating: .powder
        case .error: .blush
        }
    }

    var isInProgress: Bool {
        switch self {
        case .heating, .flushing, .backflushing, .descaling, .updating: true
        case .ready, .error: false
        }
    }

    var ink: Color {
        switch self {
        case .ready: .jade
        case .heating: .terracotta
        case .flushing, .backflushing, .descaling, .updating: .denim
        case .error: .raspberry
        }
    }
}

#Preview("Boiler card") {
    let states: [BoilerState] = [.ready, .heating, .flushing, .backflushing, .descaling, .updating, .error(code: 4)]
    NavigationStack {
        ScrollView {
            VStack(spacing: .spacing16) {
                ForEach(states.indices, id: \.self) { index in
                    BoilerCard(readings: .sample(endingAt: .now), state: states[index])
                }
            }
            .padding(.horizontal, .spacing16)
        }
        .background(.cream)
    }
}
