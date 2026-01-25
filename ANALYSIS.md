# Ambxst Analysis Report

## 1. CircularControl.qml - Half-Circle / Partial Circle Drawing

### Overview
`CircularControl.qml` implements a **partial circular progress ring** using Canvas 2D context with gap-based angles.

### Key Angle Logic

**Lines 30, 104, 123-126, 159-160:**
```qml
property real gapAngle: 45  // Gap from each end (default 45°, so 90° total)
property real angle: root.value * (360 - 2 * root.gapAngle)  // Maps value to available angle
```

**How it works:**
1. **Start angle**: `baseStartAngle = π/2 + (gapAngle in radians)` (90° plus gap, places it at top-left of the circle)
2. **Total drawable angle**: `360° - 2 × gapAngle` (default: 360 - 90 = 270°)
3. **Value mapping**: `angle = value × (360 - 2 × gapAngle)` converts 0-1 value to drawable degrees
4. **Three arc sections**:
   - **Progress arc** (lines 129-136): From baseStartAngle to (baseStartAngle + progressAngle - handleGap)
   - **Handle** (lines 138-155): A radial line perpendicular to the circle at the current position
   - **Remaining arc** (lines 157-168): From (baseStartAngle + progressAngle + handleGap) to end

### Key Differences from CircularSeekBar

| Aspect | CircularControl | CircularSeekBar |
|--------|-----------------|-----------------|
| **Coverage** | ~270° (gapAngle=45°) | Full 360° circle |
| **Start Angle** | `π/2 + gapAngle` | `-π/2` (top of circle) |
| **Gap Handling** | Has explicit handle gaps | No gap between progress and handle |
| **Canvas Complexity** | Higher (3 arcs: progress, handle, remaining) | Lower (2 parts: track, progress) |
| **Visual Effect** | Partial ring with gaps | Full ring fill from top |

---

## 2. FullPlayer.qml - Player Selector Icon Issue

### The Bug: Hardcoded vs. Dynamic Icon

**Line 210 - Main Selector Button:**
```qml
MediaIconButton {
    icon: Icons.player  // ❌ HARDCODED - always shows generic player icon
    onClicked: player.playersListExpanded = !player.playersListExpanded
}
```

**Lines 342 - List Item Icons (CORRECT):**
```qml
Text {
    text: player.getPlayerIcon(modelData)  // ✓ CORRECT - calls getPlayerIcon()
    font.family: Icons.font
    ...
}
```

### Root Cause
The main player selector button directly uses `Icons.player` instead of calling the `getPlayerIcon()` function with `MprisController.activePlayer`.

### The `getPlayerIcon()` Function (Lines 394-410)
```qml
function getPlayerIcon(player) {
    if (!player)
        return Icons.player;
    const dbusName = (player.dbusName || "").toLowerCase();
    const desktopEntry = (player.desktopEntry || "").toLowerCase();
    const identity = (player.identity || "").toLowerCase();

    if (dbusName.includes("spotify") || desktopEntry.includes("spotify") || identity.includes("spotify"))
        return Icons.spotify;
    if (dbusName.includes("chromium") || dbusName.includes("chrome") || desktopEntry.includes("chromium") || desktopEntry.includes("chrome"))
        return Icons.chromium;
    if (dbusName.includes("firefox") || desktopEntry.includes("firefox"))
        return Icons.firefox;
    if (dbusName.includes("telegram") || desktopEntry.includes("telegram") || identity.includes("telegram"))
        return Icons.telegram;
    return Icons.player;
}
```

**Detection Logic (in order):**
1. **Spotify** - dbusName, desktopEntry, or identity contains "spotify"
2. **Chromium/Chrome** - dbusName or desktopEntry contains "chromium" or "chrome"
3. **Firefox** - dbusName or desktopEntry contains "firefox"
4. **Telegram** - dbusName, desktopEntry, or identity contains "telegram"
5. **Fallback** - Generic `Icons.player`

### How List Items Work (Correctly)
The delegate (lines 326-367) properly calls `player.getPlayerIcon(modelData)` where `modelData` is the player object from the `MprisController.filteredPlayers` model. This means:
- ✓ List items show correct app-specific icons (Spotify → 🎵, Firefox → 🦊, etc.)
- ✓ Dynamic updates when player changes
- ✓ Uses the `getPlayerIcon()` function meant for icon resolution

### Inconsistency
- **List items**: Dynamic, correct, via `getPlayerIcon(MprisController.activePlayer)`
- **Main button**: Static generic icon (`Icons.player`), never updates

---

## 3. Player Selector Button - Interaction Logic

### Line 211 - Click Handler
```qml
onClicked: player.playersListExpanded = !player.playersListExpanded
```

**Behavior:**
- **Left-click**: Toggle the `playersListExpanded` boolean
- **Right-click**: Not handled (ignored, only Left Button accepted by default)

### Overlay Mechanism (Lines 289-370)
- **Scrim** (lines 296-305): Semi-transparent black overlay with click-to-close
- **Players List Container** (lines 309-369): Slides up from bottom with list of available players
- **List Selection** (lines 357-366): Clicking a player calls `MprisController.setActivePlayer(modelData)`

### Current Limitations
1. ✗ **No right-click support** - Could allow context menu or direct player switching
2. ✗ **No wheel scroll** - No mouse wheel cycling through players
3. ✗ **No keyboard shortcuts** - No arrow keys or number keys to switch players
4. ✓ **Left-click** - Opens/closes the list overlay

---

## 4. LockPlayer.qml - Comparison (Has Same Function)

**Lines 413-429:** LockPlayer implements identical `getPlayerIcon()` function.

**Lines 441:** Uses it correctly in menu items:
```qml
icon: getPlayerIcon(player),
```

Unlike FullPlayer, LockPlayer appears to use the function properly in its menu items.

---

## Summary of Findings

### CircularControl.qml ✓
- Well-designed partial circle implementation
- Gap angle system allows flexible ring coverage
- Canvas drawing properly handles start/end angles
- Used correctly in CircularControl (media controls ring)

### FullPlayer.qml Icon Bug ✗
- **Line 210**: Main button uses hardcoded `Icons.player` instead of `getPlayerIcon(MprisController.activePlayer)`
- **Line 342**: List items correctly use `getPlayerIcon(modelData)`
- **Fix**: Change line 210 from `Icons.player` to dynamic icon via `getPlayerIcon()`
- **Inconsistency**: Main button doesn't visually reflect currently active player

### Player Selector Interactions ✓ (with limitations)
- Left-click toggles list: ✓ Works
- Right-click: ✗ Not implemented
- Wheel scroll: ✗ Not implemented
- Keyboard navigation: ✗ Not implemented
- List overlay: ✓ Works properly with scrim and selection
