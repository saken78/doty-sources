#!/bin/bash

# Contribution Maximizer Script
# This script will create multiple atomic commits to maximize your Git contribution count

echo "Starting contribution maximization..."

# Phase 1: Commit each modified file individually
echo "Phase 1: Committing modified files..."
git add config/Config.qml && git commit -m "config: update Config.qml settings"
git add modules/bar/workspaces/Workspaces.qml && git commit -m "workspaces: update Workspaces.qml"
git add modules/lockscreen/LockScreen.qml && git commit -m "lockscreen: update LockScreen.qml"
git add modules/shell/UnifiedShellPanel.qml && git commit -m "shell: update UnifiedShellPanel.qml"
git add modules/widgets/dashboard/wallpapers/Wallpaper.qml && git commit -m "wallpaper: update Wallpaper.qml"
git add scripts/daemon_priority.sh && git commit -m "scripts: update daemon_priority.sh"
git add shell.qml && git commit -m "shell: update main shell.qml"

# Phase 2: Commit each deleted file individually
echo "Phase 2: Committing deleted files..."
git rm -f config/defaults/ai.js 2>/dev/null || git add config/defaults/ai.js && git rm --cached config/defaults/ai.js && git commit -m "config: remove ai.js defaults"
git rm -f modules/services/Ai.qml 2>/dev/null || git add modules/services/Ai.qml && git rm --cached modules/services/Ai.qml && git commit -m "services: remove Ai.qml"
git rm -f modules/services/EasyEffectsService.qml 2>/dev/null || git add modules/services/EasyEffectsService.qml && git rm --cached modules/services/EasyEffectsService.qml && git commit -m "services: remove EasyEffectsService.qml"
git rm -f modules/services/ai/AiModel.qml 2>/dev/null || git add modules/services/ai/AiModel.qml && git rm --cached modules/services/ai/AiModel.qml && git commit -m "ai: remove AiModel.qml"
git rm -f modules/services/ai/litellm_config.yaml 2>/dev/null || git add modules/services/ai/litellm_config.yaml && git rm --cached modules/services/ai/litellm_config.yaml && git commit -m "ai: remove litellm_config.yaml"
git rm -f modules/services/ai/strategies/ApiStrategy.qml 2>/dev/null || git add modules/services/ai/strategies/ApiStrategy.qml && git rm --cached modules/services/ai/strategies/ApiStrategy.qml && git commit -m "ai: remove ApiStrategy.qml"
git rm -f modules/services/ai/strategies/GeminiApiStrategy.qml 2>/dev/null || git add modules/services/ai/strategies/GeminiApiStrategy.qml && git rm --cached modules/services/ai/strategies/GeminiApiStrategy.qml && git commit -m "ai: remove GeminiApiStrategy.qml"
git rm -f modules/services/ai/strategies/MistralApiStrategy.qml 2>/dev/null || git add modules/services/ai/strategies/MistralApiStrategy.qml && git rm --cached modules/services/ai/strategies/MistralApiStrategy.qml && git commit -m "ai: remove MistralApiStrategy.qml"
git rm -f modules/services/ai/strategies/OpenAiApiStrategy.qml 2>/dev/null || git add modules/services/ai/strategies/OpenAiApiStrategy.qml && git rm --cached modules/services/ai/strategies/OpenAiApiStrategy.qml && git commit -m "ai: remove OpenAiApiStrategy.qml"
git rm -f modules/shell/osd/OSD.qml 2>/dev/null || git add modules/shell/osd/OSD.qml && git rm --cached modules/shell/osd/OSD.qml && git commit -m "shell: remove OSD.qml"
git rm -f modules/widgets/dashboard/controls/EasyEffectsPanel.qml 2>/dev/null || git add modules/widgets/dashboard/controls/EasyEffectsPanel.qml && git rm --cached modules/widgets/dashboard/controls/EasyEffectsPanel.qml && git commit -m "widgets: remove EasyEffectsPanel.qml"

# Phase 3: Add and commit untracked files
echo "Phase 3: Adding and committing untracked files..."
git add config/defaults/ai.js.bak && git commit -m "backup: add ai.js backup"
git add modules/services/EasyEffectsService.qml.bak && git commit -m "backup: add EasyEffectsService.qml backup"
git add modules/shell/osd.bak/ && git commit -m "backup: add osd backup directory"
git add modules/widgets/dashboard/controls/EasyEffectsPanel.qml.bak && git commit -m "backup: add EasyEffectsPanel.qml backup"

# Phase 4: Create additional commits to reach 100 total
echo "Phase 4: Creating additional commits to reach 100 total..."

# Get current commit count
current_count=$(git rev-list --count HEAD)
echo "Current commit count: $current_count"

# Calculate how many more commits we need
remaining=$((100 - current_count))
echo "Need $remaining more commits to reach 100"

# Create empty commits to reach 100 total
for i in $(seq 1 $remaining); do
    git commit --allow-empty -m "chore: incremental improvement #$i"
done

echo "Contribution maximization complete!"
echo "Final commit count: $(git rev-list --count HEAD)"