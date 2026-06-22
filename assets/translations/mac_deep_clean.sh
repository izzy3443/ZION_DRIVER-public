#!/usr/bin/env bash
set -u

echo "macOS Deep Clean Script for Developers (Flutter/Xcode/Android Studio)"
echo "--------------------------------------------------------------------"
echo "This script will OFFER to remove caches in steps. Nothing is deleted"
echo "without your confirmation. Close Xcode, Android Studio, Simulators,"
echo "Emulators, Docker, and browsers BEFORE running."
echo

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script is intended for macOS only."
  exit 1
fi

ask() {
  # $1 = prompt
  read -r -p "$1 [y/N]: " yn
  case "$yn" in
    [Yy]*) return 0;;
    *)     return 1;;
  esac
}

# 0) Built-in storage recommendations
echo "0) TIP: System Settings > General > Storage -> run recommendations (manual)."
echo

# 1) General USER caches & logs
if ask "1) Clear USER caches & logs (~Library/Caches, Logs, Saved Application State)?"; then
  rm -rf "$HOME/Library/Caches/"* || true
  rm -rf "$HOME/Library/Logs/"* || true
  rm -rf "$HOME/Library/Saved Application State/"* || true
  echo "✓ Cleared user caches/logs."
fi

# 2) SYSTEM caches (safe, will recreate) - requires sudo
if ask "2) Clear SYSTEM caches (/Library/Caches) (requires sudo)?"; then
  sudo rm -rf "/Library/Caches/"* || true
  echo "✓ Cleared system caches."
fi

# 3) Browser caches
if ask "3a) Clear Safari cache? (will sign you out of some sites)"; then
  rm -rf "$HOME/Library/Caches/com.apple.Safari/"* || true
  rm -rf "$HOME/Library/Caches/com.apple.WebKit.Networking/"* || true
  rm -rf "$HOME/Library/Caches/com.apple.WebKit.WebContent/"* || true
  echo "✓ Cleared Safari cache."
fi

if ask "3b) Clear Chrome caches for all profiles? (Cache, Code Cache, GPUCache)"; then
  CHROME_BASE="$HOME/Library/Application Support/Google/Chrome"
  if [[ -d "$CHROME_BASE" ]]; then
    for prof in "$CHROME_BASE"/Default "$CHROME_BASE"/Profile*; do
      [[ -d "$prof" ]] || continue
      rm -rf "$prof/Cache" "$prof/Code Cache" "$prof/GPUCache" || true
    done
  fi
  rm -rf "$HOME/Library/Caches/Google/Chrome/"* || true
  echo "✓ Cleared Chrome caches."
fi

# 4) Xcode caches, DerivedData, archives, simulators
if ask "4a) Clear Xcode DerivedData, ModuleCache, DeviceSupport, Archives, and Xcode caches?"; then
  rm -rf "$HOME/Library/Developer/Xcode/DerivedData/"* || true
  rm -rf "$HOME/Library/Developer/Xcode/Archives/"* || true
  rm -rf "$HOME/Library/Developer/Xcode/iOS DeviceSupport/"* || true
  rm -rf "$HOME/Library/Caches/com.apple.dt.Xcode/"* || true
  echo "✓ Cleared Xcode caches and build products."
fi

if ask "4b) Delete UNAVAILABLE simulators and ERASE ALL simulator data? (keeps runtimes)"; then
  xcrun simctl delete unavailable || true
  xcrun simctl erase all || true
  echo "✓ Simulators cleaned."
fi

# 5) CocoaPods
if ask "5) Clean CocoaPods cache (pod cache clean --all)?"; then
  pod cache clean --all || true
  echo "✓ CocoaPods cache cleaned."
fi

# 6) Flutter caches
if ask "6a) Clean global Dart/Flutter pub cache (~/.pub-cache)? (will re-download packages)"; then
  rm -rf "$HOME/.pub-cache" || true
  echo "✓ Removed ~/.pub-cache."
fi
if ask "6b) Clean Flutter SDK bin/cache (forces re-download of engine/Dart on next run)?"; then
  if command -v flutter >/dev/null 2>&1; then
    FLUTTER_BIN="$(command -v flutter)"
    FLUTTER_ROOT="$(cd "$(dirname "$FLUTTER_BIN")/.." && pwd)"
    rm -rf "$FLUTTER_ROOT/bin/cache" || true
    echo "✓ Removed Flutter bin/cache at $FLUTTER_ROOT/bin/cache"
  else
    echo "! flutter not found in PATH; skipped."
  fi
fi

# 7) Android / Gradle / Studio / AVD
if ask "7a) Stop Gradle daemons and clear ~/.gradle caches/daemon/wrappers?"; then
  pkill -f GradleDaemon || true
  rm -rf "$HOME/.gradle/caches" "$HOME/.gradle/daemon" "$HOME/.gradle/wrapper/dists" || true
  echo "✓ Gradle caches cleared."
fi

if ask "7b) Clear Android Studio caches (may reset indexes, plugins remain)?"; then
  rm -rf "$HOME/Library/Caches/Google/AndroidStudio"* || true
  echo "✓ Android Studio caches cleared."
fi

if ask "7c) Delete ALL Android emulators (AVDs) data? (You can recreate later)"; then
  rm -rf "$HOME/.android/avd/"* || true
  echo "✓ Deleted AVDs."
fi

# 8) Homebrew cleanup
if command -v brew >/dev/null 2>&1; then
  if ask "8) Run 'brew cleanup -s' and 'brew autoremove', and clear Homebrew user cache?"; then
    brew cleanup -s || true
    brew autoremove || true
    rm -rf "$HOME/Library/Caches/Homebrew/"* || true
    echo "✓ Homebrew cleaned."
  fi
fi

# 9) Docker (optional, frees a lot)
if command -v docker >/dev/null 2>&1; then
  if ask "9) Docker prune (images/containers/networks/volumes) - DANGEROUS if you rely on them"; then
    docker system prune -af --volumes || true
    echo "✓ Docker pruned."
  fi
fi

# 10) Old iOS device backups (Finder/iTunes)
if ask "10) Remove old iOS device backups? (~/Library/Application Support/MobileSync/Backup)"; then
  rm -rf "$HOME/Library/Application Support/MobileSync/Backup/"* || true
  echo "✓ iOS backups removed."
fi

# 11) Empty Trash
if ask "11) Empty Trash (~/.Trash)?"; then
  rm -rf "$HOME/.Trash/"* || true
  echo "✓ Trash emptied."
fi

# 12) Rotate logs & (optional) rebuild Spotlight
if ask "12a) Run periodic daily/weekly/monthly (sudo) to rotate logs?"; then
  sudo periodic daily weekly monthly || true
  echo "✓ Ran periodic maintenance."
fi
if ask "12b) Rebuild Spotlight index (can take time)?"; then
  sudo mdutil -E / || true
  echo "✓ Spotlight reindex started."
fi

echo
echo "All selected steps done. It's a good idea to RESTART now."
echo "Disk usage:"
df -h /
