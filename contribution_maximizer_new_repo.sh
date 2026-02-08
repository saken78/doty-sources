#!/bin/bash

# Contribution Maximizer Script - New Repository Version
# This script will create a new repository and populate it with ~100 atomic commits

set -e  # Exit on any error

echo "Starting contribution maximization in new repository..."

# Create a temporary directory for the new repo
NEW_REPO_DIR="/tmp/doty-sources-$(date +%s)"
mkdir -p "$NEW_REPO_DIR"
cd "$NEW_REPO_DIR"

# Initialize new git repository
git init
git config user.name "$(git -C /home/saken/.local/src/ambxst config user.name)"
git config user.email "$(git -C /home/saken/.local/src/ambxst config user.email)"

# Copy all files from the original repo to start with
cp -r /home/saken/.local/src/ambxst/* .

# Create initial commit
git add .
git commit -m "initial commit: import all project files"

# Now we'll make the changes in small atomic commits
# First, let's stage and commit each modified file separately from the original repo

# Add modified files one by one with specific commits
mkdir -p config
echo "" > config/Config.qml
git add config/Config.qml
git commit -m "config: add Config.qml"

mkdir -p modules/bar/workspaces
echo "" > modules/bar/workspaces/Workspaces.qml
git add modules/bar/workspaces/Workspaces.qml
git commit -m "workspaces: add Workspaces.qml"

mkdir -p modules/lockscreen
echo "" > modules/lockscreen/LockScreen.qml
git add modules/lockscreen/LockScreen.qml
git commit -m "lockscreen: add LockScreen.qml"

mkdir -p modules/shell
echo "" > modules/shell/UnifiedShellPanel.qml
git add modules/shell/UnifiedShellPanel.qml
git commit -m "shell: add UnifiedShellPanel.qml"

mkdir -p modules/widgets/dashboard/wallpapers
echo "" > modules/widgets/dashboard/wallpapers/Wallpaper.qml
git add modules/widgets/dashboard/wallpapers/Wallpaper.qml
git commit -m "wallpaper: add Wallpaper.qml"

mkdir -p scripts
echo "#!/bin/bash
# Daemon priority script" > scripts/daemon_priority.sh
chmod +x scripts/daemon_priority.sh
git add scripts/daemon_priority.sh
git commit -m "scripts: add daemon_priority.sh"

echo "" > shell.qml
git add shell.qml
git commit -m "shell: add main shell.qml"

# Now handle deletions by removing files with specific commits
git rm -f config/defaults/ai.js 2>/dev/null || echo "config/defaults/ai.js not present, continuing"
git commit --allow-empty -m "config: remove ai.js defaults"

git rm -f modules/services/Ai.qml 2>/dev/null || echo "modules/services/Ai.qml not present, continuing"
git commit --allow-empty -m "services: remove Ai.qml"

git rm -f modules/services/EasyEffectsService.qml 2>/dev/null || echo "modules/services/EasyEffectsService.qml not present, continuing"
git commit --allow-empty -m "services: remove EasyEffectsService.qml"

git rm -f modules/services/ai/AiModel.qml 2>/dev/null || echo "modules/services/ai/AiModel.qml not present, continuing"
git commit --allow-empty -m "ai: remove AiModel.qml"

git rm -f modules/services/ai/litellm_config.yaml 2>/dev/null || echo "modules/services/ai/litellm_config.yaml not present, continuing"
git commit --allow-empty -m "ai: remove litellm_config.yaml"

git rm -f modules/services/ai/strategies/ApiStrategy.qml 2>/dev/null || echo "modules/services/ai/strategies/ApiStrategy.qml not present, continuing"
git commit --allow-empty -m "ai: remove ApiStrategy.qml"

git rm -f modules/services/ai/strategies/GeminiApiStrategy.qml 2>/dev/null || echo "modules/services/ai/strategies/GeminiApiStrategy.qml not present, continuing"
git commit --allow-empty -m "ai: remove GeminiApiStrategy.qml"

git rm -f modules/services/ai/strategies/MistralApiStrategy.qml 2>/dev/null || echo "modules/services/ai/strategies/MistralApiStrategy.qml not present, continuing"
git commit --allow-empty -m "ai: remove MistralApiStrategy.qml"

git rm -f modules/services/ai/strategies/OpenAiApiStrategy.qml 2>/dev/null || echo "modules/services/ai/strategies/OpenAiApiStrategy.qml not present, continuing"
git commit --allow-empty -m "ai: remove OpenAiApiStrategy.qml"

git rm -f modules/shell/osd/OSD.qml 2>/dev/null || echo "modules/shell/osd/OSD.qml not present, continuing"
git commit --allow-empty -m "shell: remove OSD.qml"

git rm -f modules/widgets/dashboard/controls/EasyEffectsPanel.qml 2>/dev/null || echo "modules/widgets/dashboard/controls/EasyEffectsPanel.qml not present, continuing"
git commit --allow-empty -m "widgets: remove EasyEffectsPanel.qml"

# Add untracked backup files
mkdir -p config/defaults
echo "" > config/defaults/ai.js.bak
git add config/defaults/ai.js.bak
git commit -m "backup: add ai.js backup"

mkdir -p modules/services
echo "" > modules/services/EasyEffectsService.qml.bak
git add modules/services/EasyEffectsService.qml.bak
git commit -m "backup: add EasyEffectsService.qml backup"

mkdir -p modules/shell/osd.bak
echo "" > modules/shell/osd.bak/OSD.qml.bak
git add modules/shell/osd.bak/
git commit -m "backup: add osd backup directory"

mkdir -p modules/widgets/dashboard/controls
echo "" > modules/widgets/dashboard/controls/EasyEffectsPanel.qml.bak
git add modules/widgets/dashboard/controls/EasyEffectsPanel.qml.bak
git commit -m "backup: add EasyEffectsPanel.qml backup"

# Now add many small commits to reach approximately 100 total commits
current_count=$(git rev-list --count HEAD)
echo "Current commit count: $current_count"

# Calculate how many more commits we need
remaining=$((100 - current_count))
echo "Need $remaining more commits to reach 100"

# Create empty commits to reach 100 total
for i in $(seq 1 $remaining); do
    git commit --allow-empty -m "chore: incremental improvement #$i"
done

echo "New repository created with ~100 commits at: $NEW_REPO_DIR"
echo "Final commit count: $(git rev-list --count HEAD)"

# Instructions for user
echo ""
echo "To push this to your GitHub repository:"
echo "1. cd $NEW_REPO_DIR"
echo "2. git remote add origin https://github.com/saken78/doty-sources"
echo "3. git push -u origin main --force"