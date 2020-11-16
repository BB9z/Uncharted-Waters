#!/bin/sh
set -euo pipefail
cd "$(dirname "$0")"
echo $PWD

logInfo() {
    echo "\033[32m$1\033[0m" >&2
}

logWarning() {
    echo "\033[33m$1\033[0m" >&2
}

logError() {
    echo "\033[31m$1\033[0m" >&2
}

logInfo "⛵️ 构建安装"
xcodebuild install -scheme uw2yz DSTROOT="/"

location=$(which uw2yz)
logInfo "🎉 安装在 $location"
