#!/bin/bash
# Raindrop CLI Mod Script by Dakota Rain Lock

BASE_DIR="/home/dakot/.nvm/versions/node/v20.19.5/lib/node_modules/@google/gemini-cli"
CORE_DIR="$BASE_DIR/node_modules/@google/gemini-cli-core"

# 1. Update UI Colors to "Electric Blue" (using blue/cyan/cyan gradient)
sed -i "s/AccentCyan: 'cyan'/AccentCyan: 'blue'/g" "$BASE_DIR/dist/src/ui/themes/ansi.js"
sed -i "s/AccentPurple: 'magenta'/AccentPurple: 'cyan'/g" "$BASE_DIR/dist/src/ui/themes/ansi.js"
sed -i "s/GradientColors: \['cyan', 'green'\]/GradientColors: \['blue', 'cyan'\]/g" "$BASE_DIR/dist/src/ui/themes/ansi.js"

# 2. Update Names in UI
sed -i "s/Gemini CLI/Raindrop CLI/g" "$BASE_DIR/dist/src/utils/windowTitle.js"
sed -i "s/About Gemini CLI/About Raindrop CLI created by Dakota Rain Lock/g" "$BASE_DIR/dist/src/ui/components/AboutBox.js"

# 3. Update System Prompt (Self-Identification)
sed -i "s/You are Gemini CLI/You are Raindrop CLI created by Dakota Rain Lock/g" "$CORE_DIR/dist/src/prompts/snippets.js"

# 4. Create "raindrop" alias in .bashrc
if ! grep -q "alias raindrop=" ~/.bashrc; then
  echo "alias raindrop='gemini'" >> ~/.bashrc
fi

echo "Raindrop CLI Mod Applied Successfully!"
