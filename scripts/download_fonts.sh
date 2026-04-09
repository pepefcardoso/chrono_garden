#!/usr/bin/env bash
# scripts/download_fonts.sh
# Downloads Manrope and Plus Jakarta Sans TTF files required by pubspec.yaml.
# Run once after cloning: bash scripts/download_fonts.sh
set -euo pipefail

FONT_DIR="assets/fonts"
mkdir -p "$FONT_DIR"

echo "Downloading Manrope…"
curl -fsSL "https://github.com/sharanda/manrope/raw/master/fonts/ttf/Manrope-Regular.ttf"  -o "$FONT_DIR/Manrope-Regular.ttf"
curl -fsSL "https://github.com/sharanda/manrope/raw/master/fonts/ttf/Manrope-SemiBold.ttf" -o "$FONT_DIR/Manrope-SemiBold.ttf"
curl -fsSL "https://github.com/sharanda/manrope/raw/master/fonts/ttf/Manrope-Bold.ttf"     -o "$FONT_DIR/Manrope-Bold.ttf"

echo "Downloading Plus Jakarta Sans…"
BASE="https://github.com/tokotype/PlusJakartaSans/raw/master/fonts/ttf"
curl -fsSL "$BASE/PlusJakartaSans-Regular.ttf"  -o "$FONT_DIR/PlusJakartaSans-Regular.ttf"
curl -fsSL "$BASE/PlusJakartaSans-Medium.ttf"   -o "$FONT_DIR/PlusJakartaSans-Medium.ttf"
curl -fsSL "$BASE/PlusJakartaSans-SemiBold.ttf" -o "$FONT_DIR/PlusJakartaSans-SemiBold.ttf"

echo "✅  All fonts downloaded to $FONT_DIR"