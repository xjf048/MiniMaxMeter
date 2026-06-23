import SwiftUI

/// 永远显示在菜单栏的精简 label
struct MenuBarLabel: View {
    @ObservedObject var store: UsageStore

    var body: some View {
        HStack(spacing: 4) {
            if store.snapshot == nil {
                Image(systemName: "wifi.exclamationmark")
                    .foregroundStyle(.secondary)
                Text("MiniMax").font(.system(size: 12, weight: .medium))
            } else {
                Text(labelText)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(.primary)
            }
        }
    }

    /// 例：`5h 25% / 周 18%`
    private var labelText: String {
        guard let s = store.snapshot else { return "—" }
        let h = s.fiveHour.usedPercent
        let w = s.weekly.usedPercent
        return "5h \(h)% / 周 \(w)%"
    }
}
