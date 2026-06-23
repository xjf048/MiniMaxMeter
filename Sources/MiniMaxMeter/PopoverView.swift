import SwiftUI

struct PopoverView: View {
    @EnvironmentObject var store: UsageStore
    @State private var now = Date()
    @State private var tickTimer: Timer?
    @State private var showSettings: Bool = false
    @State private var cookieDraft: String = ""
    @State private var savedHint: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            if let s = store.snapshot {
                QuotaRow(title: "5h 限额", quota: s.fiveHour, color: store.fiveHourColor)
                QuotaRow(title: "周限额", quota: s.weekly, color: store.weeklyColor)
            } else {
                placeholder
            }

            if let err = store.lastError {
                Text(err)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .lineLimit(2)
            }

            if showSettings {
                Divider()
                settingsSection
            }

            Divider()
            toolbar
        }
        .padding(16)
        .frame(width: 360)
        .onAppear {
            startTicking()
            if !store.hasCookie { showSettings = true }   // 首次没 Cookie 自动展开
        }
        .onDisappear { stopTicking() }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("MiniMax Token")
                .font(.headline)
            Spacer()
            if let s = store.snapshot {
                Text("更新于 \(s.fetchedAt, style: .time)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Placeholder

    private var placeholder: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("还没有数据")
                .font(.subheadline.bold())
            Text("展开「设置」粘贴 platform.minimaxi.com 的 cookie 字符串")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Settings (inline)

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Cookie").font(.caption.bold())
                Spacer()
                if store.hasCookie {
                    Label("已配置", systemImage: "checkmark.circle.fill")
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.green)
                }
            }
            SecureField("粘贴 cookie 值（不含 `cookie:` 前缀）", text: $cookieDraft)
                .textFieldStyle(.roundedBorder)
            HStack {
                Button("保存") {
                    store.setCookie(cookieDraft)
                    cookieDraft = ""
                    savedHint = true
                    Task { try? await Task.sleep(nanoseconds: 2_000_000_000); savedHint = false }
                }
                .disabled(cookieDraft.isEmpty)
                Button("清除") {
                    store.clearCookie()
                    cookieDraft = ""
                }
                .foregroundStyle(.red)
                Spacer()
                if savedHint {
                    Text("已保存 ✓").font(.caption).foregroundStyle(.green)
                }
            }

            Text("刷新频率").font(.caption.bold()).padding(.top, 4)
            Picker("刷新频率", selection: $store.refreshInterval) {
                Text("30 秒").tag(TimeInterval(30))
                Text("1 分钟").tag(TimeInterval(60))
                Text("2 分钟").tag(TimeInterval(120))
                Text("5 分钟").tag(TimeInterval(300))
            }
            .pickerStyle(.segmented)
            .onChange(of: store.refreshInterval) { _ in store.restart() }
        }
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        HStack(spacing: 8) {
            Button {
                Task { await store.refresh() }
            } label: {
                Label("刷新", systemImage: "arrow.clockwise")
            }
            .controlSize(.small)

            Button {
                showSettings.toggle()
            } label: {
                Label(showSettings ? "收起" : "设置", systemImage: showSettings ? "chevron.up" : "gear")
            }
            .controlSize(.small)

            Spacer()

            Button {
                if let url = URL(string: "https://platform.minimaxi.com/console/usage") {
                    NSWorkspace.shared.open(url)
                }
            } label: {
                Label("打开网页", systemImage: "safari")
            }
            .controlSize(.small)

            Button {
                NSApp.terminate(nil)
            } label: {
                Label("退出", systemImage: "power")
            }
            .controlSize(.small)
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - Ticking

    private func startTicking() {
        now = Date()
        tickTimer?.invalidate()
        tickTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            now = Date()
        }
    }

    private func stopTicking() {
        tickTimer?.invalidate()
        tickTimer = nil
    }
}

// MARK: - QuotaRow

struct QuotaRow: View {
    let title: String
    let quota: Quota
    let color: Color

    private var liveRemaining: TimeInterval {
        max(0, quota.resetAt.timeIntervalSinceNow)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title).font(.subheadline.bold())
                Spacer()
                Text("总额度 \(quota.totalPercent)%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // 灰色背景 = 剩余额度（剩余多少就空多少）
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.15))
                    // 彩色前景 = 已用部分（从左往右，已用多少就填多少）
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: max(2, geo.size.width * quota.usedFraction))
                }
            }
            .frame(height: 8)
            HStack {
                Text("已用 \(quota.usedPercent)%")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(Quota.format(remainingSeconds: liveRemaining)) 后重置")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
