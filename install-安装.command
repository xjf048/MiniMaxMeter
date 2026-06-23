#!/bin/bash
# install-安装.command
# 在本目录双击运行：编译 + 打包 .app + 创建桌面替身
# 需已安装 Xcode Command Line Tools（终端跑 `xcode-select --install`）

set -e
cd "$(dirname "$0")"

APP="MiniMaxMeter.app"
DESKTOP_LINK="$HOME/Desktop/$APP"

# 已经装过就提示重新
if [ -d "$APP" ]; then
    echo "检测到已存在的 $APP，将重新编译..."
fi

echo "==> [1/3] 编译 release 版本..."
swift build -c release

echo "==> [2/3] 打包 .app bundle..."
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

# 复制可执行文件
cp .build/release/MiniMaxMeter "$APP/Contents/MacOS/MiniMaxMeter"
chmod +x "$APP/Contents/MacOS/MiniMaxMeter"

# 写 Info.plist（关键：LSUIElement=true 不显示 Dock 图标）
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>MiniMaxMeter</string>
    <key>CFBundleDisplayName</key>
    <string>MiniMax 用量监控</string>
    <key>CFBundleIdentifier</key>
    <string>com.MiniMax.MiniMaxMeter</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleExecutable</key>
    <string>MiniMaxMeter</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

# 清除 macOS Gatekeeper quarantine（双击不会弹"身份不明开发者"）
xattr -cr "$APP" 2>/dev/null || true

# 代码签名（ad-hoc），避免部分系统拦截
codesign --force --sign - "$APP" 2>/dev/null || true

echo "==> [3/3] 创建桌面替身..."
rm -f "$DESKTOP_LINK"
ln -sfn "$(pwd)/$APP" "$DESKTOP_LINK"

# 弹出通知
osascript -e 'display notification "双击桌面上的 MiniMaxMeter 图标启动" with title "MiniMaxMeter 安装完成"' 2>/dev/null || true

echo ""
echo "✅ 全部完成！"
echo ""
echo "  📦 主程序：$(pwd)/$APP"
echo "  🖥  桌面替身：$DESKTOP_LINK"
echo ""
echo "👉 双击桌面上的「MiniMaxMeter」即可启动"
echo "   启动后菜单栏会看到「5h X% / 周 X%」"
echo "   点菜单栏文字 → 弹出小卡片 → 点「⚙ 设置」填 Cookie"
echo ""
read -p "按回车关闭窗口..."
