#!/bin/bash
# uninstall-卸载.command
# 删除 .app + 桌面替身 + 编译产物

cd "$(dirname "$0")"

# 先 kill 进程
pkill -f "MiniMaxMeter.app/Contents/MacOS/MiniMaxMeter" 2>/dev/null || true

rm -rf "MiniMaxMeter.app"
rm -rf ".build"
rm -f "$HOME/Desktop/MiniMaxMeter.app"

echo "✅ 已卸载"
echo "   Cookie 还在 macOS Keychain 里（要清掉手动打开「钥匙串访问」搜 MiniMaxMeter）"
echo ""
read -p "按回车关闭窗口..."
