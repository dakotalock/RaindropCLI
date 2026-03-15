#!/bin/bash
# Raindrop CLI Mod Script - Universal Installer

# 0. Auto-detect Gemini Installation Path
GEMINI_PATH=$(which gemini)
if [ -z "$GEMINI_PATH" ]; then
  echo "Error: Gemini CLI not found in PATH. Install it first: npm install -g @google/gemini-cli"
  exit 1
fi

# Resolve the actual source directory from the symlink
BASE_DIR=$(readlink -f "$GEMINI_PATH" | sed 's/\/bin\/gemini//')
# If it's a global npm install, it might be in ../lib/node_modules/
if [ ! -d "$BASE_DIR/node_modules" ]; then
  BASE_DIR=$(dirname $(dirname $(readlink -f "$GEMINI_PATH")))/lib/node_modules/@google/gemini-cli
fi

CORE_DIR="$BASE_DIR/node_modules/@google/gemini-cli-core"

echo "Targeting Raindrop injection at: $BASE_DIR"

# 1. Update UI Colors to \"Electric Blue\"
sed -i "s/AccentCyan: 'cyan'/AccentCyan: 'blue'/g" "$BASE_DIR/dist/src/ui/themes/ansi.js" 2>/dev/null
sed -i "s/AccentPurple: 'magenta'/AccentPurple: 'cyan'/g" "$BASE_DIR/dist/src/ui/themes/ansi.js" 2>/dev/null
sed -i "s/GradientColors: \['cyan', 'green'\]/GradientColors: \['blue', 'cyan'\]/g" "$BASE_DIR/dist/src/ui/themes/ansi.js" 2>/dev/null

# 2. Update Names in UI
sed -i "s/Gemini CLI/Raindrop CLI/g" "$BASE_DIR/dist/src/utils/windowTitle.js" 2>/dev/null
sed -i "s/About Gemini CLI/About Raindrop CLI/g" "$BASE_DIR/dist/src/ui/components/AboutBox.js" 2>/dev/null

# 3. Update System Prompt (Self-Identification)
sed -i "s/You are Gemini CLI/You are Raindrop CLI created by Dakota Rain Lock/g" "$CORE_DIR/dist/src/prompts/snippets.js" 2>/dev/null

# 4. Create \"raindrop\" alias and setup arsenal
mkdir -p ~/.raindrop/bin
cp -r ./arsenal/* ~/.raindrop/

if ! grep -q "alias raindrop=" ~/.bashrc; then
  echo "export PATH=\"\$HOME/.raindrop/bin:\$PATH\"" >> ~/.bashrc
  echo "alias raindrop='rd-init && gemini'" >> ~/.bashrc
  echo "Raindrop alias and arsenal added to .bashrc"
fi

echo "Raindrop CLI Mod Applied Successfully! Restart your terminal or run 'source ~/.bashrc'"
