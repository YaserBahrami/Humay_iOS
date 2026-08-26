#if DEBUG
import SwiftUI

/// DEBUG-only inspector for a resolved bundled day.
struct ContentPackDebugView: View {
    let subject: ForecastSubject
    let date: Date

    @State private var snapshot: ContentPackDebugInspector.Snapshot?

    var body: some View {
        List {
            if let s = snapshot {
                Section("Canonical") {
                    LabeledContent("Date", value: date.formatted(date: .abbreviated, time: .omitted))
                    LabeledContent("DayKey", value: s.canonicalDayKey)
                    LabeledContent("Fallback", value: s.fallbackUsed ? "YES" : "NO")
                    LabeledContent("Pack", value: s.packVersion ?? s.provenance)
                    if let err = s.loadError { LabeledContent("LoadError", value: err) }
                }
                Section("Big Three") {
                    LabeledContent("Sun", value: s.sunSign ?? "—")
                    LabeledContent("Moon", value: s.moonSign ?? "— (omitted)")
                    LabeledContent("Rising", value: s.risingSign ?? "— (omitted)")
                    LabeledContent("Archetype", value: "\(s.archetypeName) (\(s.archetypeID))")
                }
                Section("Source IDs") {
                    LabeledContent("Sun record", value: s.sunRecordID ?? "none (fallback)")
                    LabeledContent("Moon mod", value: s.moonModifierID ?? "none")
                    LabeledContent("Rising mod", value: s.risingModifierID ?? "none")
                }
                Section("Scores") {
                    ForEach(s.scores.keys.sorted(), id: \.self) { k in
                        LabeledContent(k, value: "\(s.scores[k] ?? 0)")
                    }
                }
                Section("Headline") {
                    Text(s.headline ?? "— (deterministic fallback)")
                        .font(.callout)
                }
            } else {
                Text("No snapshot")
            }
        }
        .navigationTitle("Pack Debug")
        .task {
            snapshot = ContentPackDebugInspector.snapshot(subject: subject, date: date)
        }
    }
}

#Preview {
    let subject = ForecastSubject(
        id: UUID(),
        name: "Libra Cap Aries",
        birth: BirthDetails(year: 1993, month: 9, day: 23)
    )
    return NavigationStack {
        ContentPackDebugView(subject: subject, date: .now)
    }
}
#endif
