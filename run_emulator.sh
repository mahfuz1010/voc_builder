#!/usr/bin/env bash
# ============================================================
# VocBuilder — start emulator, build & run
# ============================================================
# What this script does:
#   1. Verifies SDK / Flutter are on PATH
#   2. Installs the Android 34 x86_64 system image if missing
#   3. Creates the AVD if it doesn't exist yet
#   4. Launches the emulator in the background (headless)
#   5. Waits until the device is fully booted
#   6. Runs `flutter run` on that emulator
# ============================================================

set -euo pipefail

# ── Configuration ────────────────────────────────────────────
ANDROID_SDK="${ANDROID_HOME:-/opt/dev-env2/shm/shm-app/main/core/android-sdk}"
AVD_NAME="DuoCards_Pixel5"
SYSTEM_IMAGE="system-images;android-34;google_apis;x86_64"
DEVICE_PROFILE="pixel_5"
API_LEVEL="android-34"
ABI="x86_64"
GOOGLE_APIS="google_apis"
FLUTTER="${FLUTTER_CMD:-flutter}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Helpers ──────────────────────────────────────────────────
info()    { echo -e "\033[1;34m[INFO]\033[0m  $*"; }
success() { echo -e "\033[1;32m[OK]\033[0m    $*"; }
warn()    { echo -e "\033[1;33m[WARN]\033[0m  $*"; }
die()     { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; exit 1; }

# ── Tool paths ────────────────────────────────────────────────
SDKMANAGER="$ANDROID_SDK/cmdline-tools/latest/bin/sdkmanager"
AVDMANAGER="$ANDROID_SDK/cmdline-tools/latest/bin/avdmanager"
EMULATOR="$ANDROID_SDK/emulator/emulator"
ADB="$ANDROID_SDK/platform-tools/adb"

export PATH="$ANDROID_SDK/emulator:$ANDROID_SDK/platform-tools:$ANDROID_SDK/cmdline-tools/latest/bin:/snap/bin:$PATH"
export ANDROID_HOME="$ANDROID_SDK"
export ANDROID_SDK_ROOT="$ANDROID_SDK"

# ── 1. Verify required tools ──────────────────────────────────
info "Checking required tools…"

[[ -x "$SDKMANAGER" ]] || die "sdkmanager not found at $SDKMANAGER"
[[ -x "$AVDMANAGER" ]] || die "avdmanager not found at $AVDMANAGER"
[[ -x "$EMULATOR"   ]] || die "emulator not found at $EMULATOR"
[[ -x "$ADB"        ]] || die "adb not found at $ADB"
command -v "$FLUTTER" &>/dev/null || die "flutter not found. Install Flutter or set FLUTTER_CMD."

success "All tools found."

# Ensure ADB daemon is up before querying devices.
"$ADB" start-server >/dev/null 2>&1 || true

# ── 2. Install system image if missing ───────────────────────
info "Checking system image: $SYSTEM_IMAGE…"

SYSIMG_DIR="$ANDROID_SDK/system-images/$API_LEVEL/$GOOGLE_APIS/$ABI"
if [[ -d "$SYSIMG_DIR" ]]; then
    success "System image already installed."
else
    info "Installing system image (this may take a few minutes)…"
    yes | "$SDKMANAGER" "$SYSTEM_IMAGE" 2>&1 | grep -v "^INFO" | grep -v "^\[=" || true
    [[ -d "$SYSIMG_DIR" ]] || die "System image installation failed."
    success "System image installed."
fi

# ── 3. Create AVD if it doesn't exist ────────────────────────
info "Checking AVD: $AVD_NAME…"

if "$AVDMANAGER" list avd 2>/dev/null | grep -q "Name: $AVD_NAME"; then
    success "AVD '$AVD_NAME' already exists."
else
    info "Creating AVD '$AVD_NAME'…"
    echo "no" | "$AVDMANAGER" create avd \
        --name "$AVD_NAME" \
        --package "$SYSTEM_IMAGE" \
        --device "$DEVICE_PROFILE" \
        --force 2>&1 || die "Failed to create AVD."
    success "AVD '$AVD_NAME' created."
fi

# ── 4. Check if emulator is already running ───────────────────
info "Checking for running emulators…"

RUNNING_EMULATOR=$( ("$ADB" devices 2>/dev/null | grep "^emulator-" | awk '{print $1}' | head -1) || true )

if [[ -n "$RUNNING_EMULATOR" ]]; then
    warn "Emulator already running: $RUNNING_EMULATOR — reusing it."
else
    info "Starting emulator '$AVD_NAME'…"
    DISPLAY="${DISPLAY:-:0}" "$EMULATOR" \
        -avd "$AVD_NAME" \
        -no-audio \
        -no-boot-anim \
        -gpu swiftshader_indirect \
        -memory 2048 \
        &>/tmp/duocards_emulator.log &

    EMULATOR_PID=$!
    info "Emulator PID: $EMULATOR_PID (log: /tmp/duocards_emulator.log)"
fi

# ── 5. Wait for device to fully boot ─────────────────────────
info "Waiting for emulator to come online…"

TIMEOUT=180
ELAPSED=0

until "$ADB" devices 2>/dev/null | grep -q "^emulator.*device$"; do
    sleep 3
    ELAPSED=$((ELAPSED + 3))
    if [[ $ELAPSED -ge $TIMEOUT ]]; then
        die "Emulator did not come online after ${TIMEOUT}s. Check /tmp/duocards_emulator.log"
    fi
    echo -n "."
done
echo ""

success "Emulator online. Waiting for boot to complete…"

until [[ "$("$ADB" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ]]; do
    sleep 3
    ELAPSED=$((ELAPSED + 3))
    if [[ $ELAPSED -ge $((TIMEOUT * 2)) ]]; then
        die "Boot did not complete after $((TIMEOUT * 2))s."
    fi
    echo -n "."
done
echo ""

# Dismiss lock screen
"$ADB" shell input keyevent 82 2>/dev/null || true
success "Emulator fully booted."

# ── 6. Get emulator device ID for Flutter ────────────────────
DEVICE_ID=$( ("$ADB" devices 2>/dev/null | grep "^emulator-" | awk '{print $1}' | head -1) || true )
[[ -n "$DEVICE_ID" ]] || die "Could not determine emulator device ID."
info "Device: $DEVICE_ID"

# ── 7. Build & run Flutter app ───────────────────────────────
info "Running Flutter app on $DEVICE_ID…"
cd "$SCRIPT_DIR"

"$FLUTTER" run \
    --device-id "$DEVICE_ID" \
    --debug \
    "$@"
