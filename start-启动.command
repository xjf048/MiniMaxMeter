#!/bin/bash
# start-启动.command
# 启动 MiniMaxMeter.app（先 kill 旧实例避免多开）

cd "$(dirname "$0")"

if [ ! -d "MiniMaxMeter.app" ]; then
    echo "❌ 找不到 MiniMaxMeter.app，请先双击 install-安装.command"
    read -p "按回车关闭窗口..."
    exit 1
fi

# 杀掉旧实例
pkill -f "MiniMaxMeter.app/Contents/MacOS/MiniMaxMeter" 2>/dev/null || true
sleep 0.3

# 启动
open MiniMaxMeter.app

echo "✅ 已启动，菜单栏找「5h X% / 周 X%」"
echo "   退出：点菜单栏图标 → ⚙ 设置区 → 退出按钮"
echo ""
read -p "按回车关闭窗口..."
