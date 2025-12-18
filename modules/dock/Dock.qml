pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.modules.theme
import qs.modules.services
import qs.modules.components
import qs.modules.corners
import qs.modules.globals
import qs.config

Scope {
    id: root
    
    property bool pinned: Config.dock?.pinnedOnStartup ?? false

    // Theme configuration
    readonly property string theme: Config.dock?.theme ?? "default"
    readonly property bool isFloating: theme === "floating"
    readonly property bool isDefault: theme === "default"

    // Position configuration with fallback logic to avoid bar collision
    readonly property string userPosition: Config.dock?.position ?? "bottom"
    readonly property string barPosition: Config.bar?.position ?? "top"
    
    // Effective position: if dock and bar are on the same side, dock moves to fallback
    readonly property string position: {
        if (userPosition !== barPosition) {
            return userPosition;
        }
        // Collision detected - apply fallback
        switch (userPosition) {
            case "bottom": return "left";
            case "left": return "right";
            case "right": return "left";
            case "top": return "bottom";
            default: return "bottom";
        }
    }
    
    readonly property bool isBottom: position === "bottom"
    readonly property bool isLeft: position === "left"
    readonly property bool isRight: position === "right"
    readonly property bool isVertical: isLeft || isRight

    // Margin calculations - different for each theme
    readonly property int dockMargin: Config.dock?.margin ?? 8
    readonly property int hyprlandGapsOut: Config.hyprland?.gapsOut ?? 4
    
    // For default theme: edge margin is 0, window side margin is also adjusted
    // For floating theme: both margins use dockMargin
    readonly property int windowSideMargin: {
        if (isDefault) {
            // Default: no margin on edge, normal margin on window side minus gaps
            return dockMargin > 0 ? Math.max(0, dockMargin - hyprlandGapsOut) : 0;
        } else {
            // Floating: normal margin calculation
            return dockMargin > 0 ? Math.max(0, dockMargin - hyprlandGapsOut) : 0;
        }
    }
    readonly property int edgeSideMargin: isDefault ? 0 : dockMargin

    Variants {
        model: {
            const screens = Quickshell.screens;
            const list = Config.dock?.screenList ?? [];
            if (!list || list.length === 0)
                return screens;
            return screens.filter(screen => list.includes(screen.name));
        }

        PanelWindow {
            id: dockWindow
            
            required property ShellScreen modelData
            screen: modelData

            // Reveal logic: pinned, hover, no active window
            property bool reveal: root.pinned || 
                (Config.dock?.hoverToReveal && dockMouseArea.containsMouse) || 
                !ToplevelManager.activeToplevel?.activated

            anchors {
                bottom: root.isBottom
                left: root.isLeft
                right: root.isRight
            }

            // Total margin includes dock + margins (window side + edge side)
            readonly property int totalMargin: root.windowSideMargin + root.edgeSideMargin
            readonly property int shadowSpace: 32
            readonly property int dockSize: Config.dock?.height ?? 56
            
            // Reserve space when pinned (without shadow space to not push windows too far)
            exclusiveZone: root.pinned ? dockSize + totalMargin : 0

            implicitWidth: root.isVertical 
                ? dockSize + totalMargin + shadowSpace * 2
                : dockContent.implicitWidth + shadowSpace * 2
            implicitHeight: root.isVertical
                ? dockContent.implicitHeight + shadowSpace * 2
                : dockSize + totalMargin + shadowSpace * 2
            
            WlrLayershell.namespace: "quickshell:dock"
            color: "transparent"

            mask: Region {
                item: dockMouseArea
            }

            // Content sizing helper
            Item {
                id: dockContent
                implicitWidth: root.isVertical ? dockWindow.dockSize : dockLayoutHorizontal.implicitWidth + 16
                implicitHeight: root.isVertical ? dockLayoutVertical.implicitHeight + 16 : dockWindow.dockSize
            }

            MouseArea {
                id: dockMouseArea
                hoverEnabled: true
                
                // Size
                width: root.isVertical 
                    ? (dockWindow.reveal ? dockWindow.dockSize + dockWindow.totalMargin + dockWindow.shadowSpace : (Config.dock?.hoverRegionHeight ?? 4))
                    : dockContent.implicitWidth + 20
                height: root.isVertical
                    ? dockContent.implicitHeight + 20
                    : (dockWindow.reveal ? dockWindow.dockSize + dockWindow.totalMargin + dockWindow.shadowSpace : (Config.dock?.hoverRegionHeight ?? 4))

                // Position using x/y instead of anchors to avoid sticky anchor issues
                x: root.isBottom 
                    ? (parent.width - width) / 2
                    : (root.isLeft ? 0 : parent.width - width)
                y: root.isVertical 
                    ? (parent.height - height) / 2
                    : parent.height - height

                Behavior on x {
                    enabled: Config.animDuration > 0
                    NumberAnimation { duration: Config.animDuration / 4; easing.type: Easing.OutCubic }
                }
                Behavior on y {
                    enabled: Config.animDuration > 0
                    NumberAnimation { duration: Config.animDuration / 4; easing.type: Easing.OutCubic }
                }

                Behavior on width {
                    enabled: Config.animDuration > 0 && root.isVertical
                    NumberAnimation { duration: Config.animDuration / 4; easing.type: Easing.OutCubic }
                }

                Behavior on height {
                    enabled: Config.animDuration > 0 && !root.isVertical
                    NumberAnimation { duration: Config.animDuration / 4; easing.type: Easing.OutCubic }
                }

                // Dock container
                Item {
                    id: dockContainer
                    
                    // Corner size for default theme
                    readonly property int cornerSize: root.isDefault && Config.roundness > 0 ? Config.roundness + 4 : 0
                    
                    // Size - includes corner space for default theme
                    // Bottom: corners are on left and right sides (extra width, same height)
                    // Vertical: corners are on top and bottom (same width, extra height)
                    width: {
                        if (root.isDefault && cornerSize > 0) {
                            if (root.isBottom) return dockContent.implicitWidth + cornerSize * 2;
                        }
                        return dockContent.implicitWidth;
                    }
                    height: {
                        if (root.isDefault && cornerSize > 0) {
                            if (root.isVertical) return dockContent.implicitHeight + cornerSize * 2;
                        }
                        return dockContent.implicitHeight;
                    }
                    
                    // Position using x/y
                    x: root.isBottom 
                        ? (parent.width - width) / 2
                        : (root.isLeft ? root.edgeSideMargin : parent.width - width - root.edgeSideMargin)
                    y: root.isVertical 
                        ? (parent.height - height) / 2
                        : parent.height - height - root.edgeSideMargin

                    Behavior on x {
                        enabled: Config.animDuration > 0
                        NumberAnimation { duration: Config.animDuration / 4; easing.type: Easing.OutCubic }
                    }
                    Behavior on y {
                        enabled: Config.animDuration > 0
                        NumberAnimation { duration: Config.animDuration / 4; easing.type: Easing.OutCubic }
                    }

                    // Animation for dock reveal
                    opacity: dockWindow.reveal ? 1 : 0
                    Behavior on opacity {
                        enabled: Config.animDuration > 0
                        NumberAnimation { duration: Config.animDuration / 2; easing.type: Easing.OutCubic }
                    }

                    // Slide animation
                    transform: Translate {
                        x: root.isVertical 
                            ? (dockWindow.reveal ? 0 : (root.isLeft ? -(dockContainer.width + root.edgeSideMargin) : (dockContainer.width + root.edgeSideMargin)))
                            : 0
                        y: root.isBottom 
                            ? (dockWindow.reveal ? 0 : (dockContainer.height + root.edgeSideMargin))
                            : 0
                        Behavior on x {
                            enabled: Config.animDuration > 0
                            NumberAnimation { duration: Config.animDuration / 2; easing.type: Easing.OutCubic }
                        }
                        Behavior on y {
                            enabled: Config.animDuration > 0
                            NumberAnimation { duration: Config.animDuration / 2; easing.type: Easing.OutCubic }
                        }
                    }

                    // Full background container with masking (default theme)
                    Item {
                        id: dockFullBgContainer
                        visible: root.isDefault
                        anchors.fill: parent
                        
                        // Background rect - covers the entire area
                        StyledRect {
                            id: dockBackground
                            anchors.fill: parent
                            
                            variant: "bg"
                            enableShadow: true
                            enableBorder: false
                            
                            readonly property int fullRadius: Styling.radius(4)
                            
                            // For default theme: corners on screen edge are 0 (flush with edge)
                            topLeftRadius: {
                                if (root.isBottom) return fullRadius;
                                if (root.isLeft) return 0;
                                if (root.isRight) return fullRadius;
                                return fullRadius;
                            }
                            topRightRadius: {
                                if (root.isBottom) return fullRadius;
                                if (root.isLeft) return fullRadius;
                                if (root.isRight) return 0;
                                return fullRadius;
                            }
                            bottomLeftRadius: {
                                if (root.isBottom) return 0;
                                if (root.isLeft) return 0;
                                if (root.isRight) return fullRadius;
                                return fullRadius;
                            }
                            bottomRightRadius: {
                                if (root.isBottom) return 0;
                                if (root.isLeft) return fullRadius;
                                if (root.isRight) return 0;
                                return fullRadius;
                            }
                        }
                        
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            maskEnabled: true
                            maskSource: dockMask
                            maskThresholdMin: 0.5
                            maskSpreadAtMin: 1.0
                        }
                    }

                    // Mask for the full background (default theme)
                    Item {
                        id: dockMask
                        visible: false
                        anchors.fill: parent
                        
                        layer.enabled: true
                        layer.smooth: true

                        // First corner - position and type change based on dock position
                        RoundCorner {
                            id: corner1
                            x: {
                                if (root.isBottom) return 0;
                                if (root.isLeft) return 0;  // Left edge (screen border)
                                if (root.isRight) return parent.width - dockContainer.cornerSize;  // Right edge (screen border)
                                return 0;
                            }
                            y: {
                                if (root.isBottom) return parent.height - dockContainer.cornerSize;
                                return 0;  // Top of container for vertical docks
                            }
                            size: Math.max(dockContainer.cornerSize, 1)
                            corner: {
                                if (root.isBottom) return RoundCorner.CornerEnum.BottomRight;
                                if (root.isLeft) return RoundCorner.CornerEnum.BottomLeft;  // Curves down toward dock
                                if (root.isRight) return RoundCorner.CornerEnum.BottomRight;  // Curves down toward dock
                                return RoundCorner.CornerEnum.BottomRight;
                            }
                            color: "white"
                        }
                        
                        // Second corner - position and type change based on dock position
                        RoundCorner {
                            id: corner2
                            x: {
                                if (root.isBottom) return parent.width - dockContainer.cornerSize;
                                if (root.isLeft) return 0;  // Left edge (screen border)
                                if (root.isRight) return parent.width - dockContainer.cornerSize;  // Right edge (screen border)
                                return 0;
                            }
                            y: parent.height - dockContainer.cornerSize  // Always at bottom of container
                            size: Math.max(dockContainer.cornerSize, 1)
                            corner: {
                                if (root.isBottom) return RoundCorner.CornerEnum.BottomLeft;
                                if (root.isLeft) return RoundCorner.CornerEnum.TopLeft;  // Curves up toward dock
                                if (root.isRight) return RoundCorner.CornerEnum.TopRight;  // Curves up toward dock
                                return RoundCorner.CornerEnum.BottomLeft;
                            }
                            color: "white"
                        }

                        // Center rect mask (the main dock area)
                        Rectangle {
                            id: centerMask
                            width: dockContent.implicitWidth
                            height: dockContent.implicitHeight
                            color: "white"
                            
                            // Position based on dock position
                            x: {
                                if (root.isBottom) return dockContainer.cornerSize;
                                return 0;  // Vertical docks: no x offset
                            }
                            y: {
                                if (root.isBottom) return 0;
                                return dockContainer.cornerSize;  // Vertical docks: after top corner
                            }
                            
                            topLeftRadius: dockBackground.topLeftRadius
                            topRightRadius: dockBackground.topRightRadius
                            bottomLeftRadius: dockBackground.bottomLeftRadius
                            bottomRightRadius: dockBackground.bottomRightRadius
                        }
                    }

                    // Background for floating theme (simple, no round corners)
                    StyledRect {
                        id: dockBackgroundFloating
                        visible: root.isFloating
                        anchors.fill: parent
                        variant: "bg"
                        enableShadow: true
                        radius: Styling.radius(4)
                    }

                    // Horizontal layout (bottom dock)
                    RowLayout {
                        id: dockLayoutHorizontal
                        // For default theme, center in the dock content area (not the expanded container)
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: (dockContent.implicitHeight - implicitHeight) / 2
                        spacing: Config.dock?.spacing ?? 4
                        visible: !root.isVertical
                        
                        // Pin button
                        Loader {
                            active: Config.dock?.showPinButton ?? true
                            visible: active
                            Layout.alignment: Qt.AlignVCenter
                            
                            sourceComponent: Button {
                                id: pinButton
                                implicitWidth: 32
                                implicitHeight: 32
                                
                                background: Rectangle {
                                    radius: Styling.radius(-2)
                                    color: root.pinned ? 
                                        Colors.primary : 
                                        (pinButton.hovered ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.15) : "transparent")
                                    
                                    Behavior on color {
                                        enabled: Config.animDuration > 0
                                        ColorAnimation { duration: Config.animDuration / 2 }
                                    }
                                }
                                
                                contentItem: Text {
                                    text: Icons.pin
                                    font.family: Icons.font
                                    font.pixelSize: 16
                                    color: root.pinned ? Colors.overPrimary : Colors.overBackground
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    
                                    rotation: root.pinned ? 0 : 45
                                    Behavior on rotation {
                                        enabled: Config.animDuration > 0
                                        NumberAnimation { duration: Config.animDuration / 2 }
                                    }
                                }
                                
                                onClicked: root.pinned = !root.pinned
                                
                                StyledToolTip {
                                    show: pinButton.hovered
                                    tooltipText: root.pinned ? "Unpin dock" : "Pin dock"
                                }
                            }
                        }

                        // Separator after pin button
                        Loader {
                            active: Config.dock?.showPinButton ?? true
                            visible: active
                            Layout.alignment: Qt.AlignVCenter
                            
                            sourceComponent: Separator {
                                vert: true
                                implicitHeight: (Config.dock?.iconSize ?? 40) * 0.6
                            }
                        }

                        // App buttons
                        Repeater {
                            model: TaskbarApps.apps
                            
                            DockAppButton {
                                required property var modelData
                                appToplevel: modelData
                                Layout.alignment: Qt.AlignVCenter
                                dockPosition: "bottom"
                            }
                        }

                        // Separator before overview button
                        Loader {
                            active: Config.dock?.showOverviewButton ?? true
                            visible: active
                            Layout.alignment: Qt.AlignVCenter
                            
                            sourceComponent: Separator {
                                vert: true
                                implicitHeight: (Config.dock?.iconSize ?? 40) * 0.6
                            }
                        }

                        // Overview button
                        Loader {
                            active: Config.dock?.showOverviewButton ?? true
                            visible: active
                            Layout.alignment: Qt.AlignVCenter
                            
                            sourceComponent: Button {
                                id: overviewButton
                                implicitWidth: 32
                                implicitHeight: 32
                                
                                background: Rectangle {
                                    radius: Styling.radius(-2)
                                    color: overviewButton.hovered ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.15) : "transparent"
                                    
                                    Behavior on color {
                                        enabled: Config.animDuration > 0
                                        ColorAnimation { duration: Config.animDuration / 2 }
                                    }
                                }
                                
                                contentItem: Text {
                                    text: Icons.overview
                                    font.family: Icons.font
                                    font.pixelSize: 18
                                    color: Colors.overBackground
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                onClicked: {
                                    // Toggle overview on the current screen
                                    let visibilities = Visibilities.getForScreen(dockWindow.screen.name);
                                    if (visibilities) {
                                        visibilities.overview = !visibilities.overview;
                                    }
                                }
                                
                                StyledToolTip {
                                    show: overviewButton.hovered
                                    tooltipText: "Overview"
                                }
                            }
                        }
                    }

                    // Vertical layout (left/right dock)
                    ColumnLayout {
                        id: dockLayoutVertical
                        // Center in the dock content area, accounting for corner space
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: dockContainer.cornerSize + (dockContent.implicitHeight - implicitHeight) / 2
                        spacing: Config.dock?.spacing ?? 4
                        visible: root.isVertical
                        
                        // Pin button
                        Loader {
                            active: Config.dock?.showPinButton ?? true
                            visible: active
                            Layout.alignment: Qt.AlignHCenter
                            
                            sourceComponent: Button {
                                id: pinButtonV
                                implicitWidth: 32
                                implicitHeight: 32
                                
                                background: Rectangle {
                                    radius: Styling.radius(-2)
                                    color: root.pinned ? 
                                        Colors.primary : 
                                        (pinButtonV.hovered ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.15) : "transparent")
                                    
                                    Behavior on color {
                                        enabled: Config.animDuration > 0
                                        ColorAnimation { duration: Config.animDuration / 2 }
                                    }
                                }
                                
                                contentItem: Text {
                                    text: Icons.pin
                                    font.family: Icons.font
                                    font.pixelSize: 16
                                    color: root.pinned ? Colors.overPrimary : Colors.overBackground
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    
                                    rotation: root.pinned ? 0 : 45
                                    Behavior on rotation {
                                        enabled: Config.animDuration > 0
                                        NumberAnimation { duration: Config.animDuration / 2 }
                                    }
                                }
                                
                                onClicked: root.pinned = !root.pinned
                                
                                StyledToolTip {
                                    show: pinButtonV.hovered
                                    tooltipText: root.pinned ? "Unpin dock" : "Pin dock"
                                }
                            }
                        }

                        // Separator after pin button
                        Loader {
                            active: Config.dock?.showPinButton ?? true
                            visible: active
                            Layout.alignment: Qt.AlignHCenter
                            
                            sourceComponent: Separator {
                                vert: false
                                implicitWidth: (Config.dock?.iconSize ?? 40) * 0.6
                            }
                        }

                        // App buttons
                        Repeater {
                            model: TaskbarApps.apps
                            
                            DockAppButton {
                                required property var modelData
                                appToplevel: modelData
                                Layout.alignment: Qt.AlignHCenter
                                dockPosition: root.position
                            }
                        }

                        // Separator before overview button
                        Loader {
                            active: Config.dock?.showOverviewButton ?? true
                            visible: active
                            Layout.alignment: Qt.AlignHCenter
                            
                            sourceComponent: Separator {
                                vert: false
                                implicitWidth: (Config.dock?.iconSize ?? 40) * 0.6
                            }
                        }

                        // Overview button
                        Loader {
                            active: Config.dock?.showOverviewButton ?? true
                            visible: active
                            Layout.alignment: Qt.AlignHCenter
                            
                            sourceComponent: Button {
                                id: overviewButtonV
                                implicitWidth: 32
                                implicitHeight: 32
                                
                                background: Rectangle {
                                    radius: Styling.radius(-2)
                                    color: overviewButtonV.hovered ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.15) : "transparent"
                                    
                                    Behavior on color {
                                        enabled: Config.animDuration > 0
                                        ColorAnimation { duration: Config.animDuration / 2 }
                                    }
                                }
                                
                                contentItem: Text {
                                    text: Icons.overview
                                    font.family: Icons.font
                                    font.pixelSize: 18
                                    color: Colors.overBackground
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                onClicked: {
                                    // Toggle overview on the current screen
                                    let visibilities = Visibilities.getForScreen(dockWindow.screen.name);
                                    if (visibilities) {
                                        visibilities.overview = !visibilities.overview;
                                    }
                                }
                                
                                StyledToolTip {
                                    show: overviewButtonV.hovered
                                    tooltipText: "Overview"
                                }
                            }
                        }
                    }

                    // Unified outline canvas (single continuous stroke around silhouette)
                    Canvas {
                        id: outlineCanvas
                        anchors.fill: parent
                        z: 5000
                        antialiasing: true
                        
                        readonly property var borderData: Config.theme.srBg.border
                        readonly property int borderWidth: borderData[1]
                        readonly property color borderColor: Config.resolveColor(borderData[0])
                        
                        visible: root.isDefault && borderWidth > 0
                        
                        onPaint: {
                            if (!root.isDefault)
                                return;
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            
                            if (borderWidth <= 0)
                                return;
                            
                            ctx.strokeStyle = borderColor;
                            ctx.lineWidth = borderWidth;
                            ctx.lineJoin = "round";
                            ctx.lineCap = "round";

                            var offset = borderWidth / 2;
                            var cs = dockContainer.cornerSize;
                            
                            // Floating radii
                            var tl = dockBackground.topLeftRadius;
                            var tr = dockBackground.topRightRadius;
                            var bl = dockBackground.bottomLeftRadius;
                            var br = dockBackground.bottomRightRadius;

                            ctx.beginPath();
                            
                            if (root.isBottom) {
                                // Bottom Edge is Open.
                                // Start at Bottom Right (end of Right Fillet)
                                // We are drawing from Right -> Top -> Left.
                                
                                // Right Fillet ends at (width - offset, height - cs)? No.
                                // Right Fillet: Center (width - offset, height - cs).
                                // Connects Right side (Angle 0) to Bottom Edge (Angle 90).
                                // Wait, previous code:
                                // "ACW from 180 (Left) to 90 (Bottom)" for Left Fillet?
                                // Let's re-verify the logic.
                                
                                // To have an open bottom, we should draw the path "around" the dock.
                                // Let's go Clockwise or Counter-Clockwise.
                                // Let's go from Bottom Right -> Up -> Left -> Down -> Bottom Left.
                                
                                // Start point: Bottom Right of the shape (on the screen edge).
                                // This is the end of the Right Fillet if we were coming down.
                                // Point: (width - offset, height - offset).
                                ctx.moveTo(width - offset, height - offset);
                                
                                // Right Fillet (Screen Edge -> Right Side).
                                // Center: (width - offset, height - cs).
                                // Start Angle: 90 degrees (Math.PI/2) [Bottom].
                                // End Angle: 0 degrees (0) [Right].
                                // Direction: 90 -> 0. ACW (Decreasing).
                                ctx.arc(width - offset, height - cs, cs - offset, Math.PI / 2, 0, true);
                                
                                // Line Up
                                ctx.lineTo(width - offset, cs); // to top fillet start? No, Top Right corner.
                                // Top Right Corner start
                                // If tr > 0, we stop early.
                                
                                // Wait, previous code had Top Right Corner logic:
                                // ctx.lineTo(width - cs - tr, offset); ...
                                // Let's use standard arcTo or arc logic.
                                
                                // Current pos: (width - offset, height - cs) after fillet?
                                // No, arc ends at (width + R * cos 0, ...) = (width - offset + cs - offset, ...) = (width + cs - 2offset).
                                // This is wrong.
                                // Fillet Center (width - offset, height - cs). R = cs - offset.
                                // Angle 0 point: (width - offset + cs - offset, height - cs).
                                // This pushes OUT.
                                // Fillet should be concave? No, convex relative to the dock.
                                // Dock is solid. Outline is outside.
                                // Wait, the fillet mimics the screen corner filling in?
                                // The notch code had corner masks.
                                // In notch: "Left top corner arc".
                                // This is the fillet connecting the bar to the screen.
                                // It curves IN.
                                // So the center of the circle is OUTSIDE the dock shape.
                                // Center should be at (width - cs, height - offset) ?
                                // If center is (width - cs, height - offset), and R = cs - offset.
                                // At Angle 0 (Right): (width - cs + cs - offset, height - offset) = (width - offset, height - offset).
                                // At Angle 270 (Top): (width - cs, height - offset - (cs - offset)) = (width - cs, height - cs).
                                // This connects Bottom Edge to Right Edge? No.
                                // This connects Right Edge to Bottom Edge.
                                // 0 (Right) -> 270 (-90) (Top)? No.
                                
                                // Let's stick to the previous successfully drawn shape, just change the start/end.
                                // Previous Bottom Dock:
                                // 1. Start (offset, height - offset).
                                // 2. Left Fillet: arc(offset, height - cs, cs - offset, PI/2, 0, true).
                                //    Center (offset, height - cs).
                                //    Start Angle PI/2 (Bottom). Point: (offset, height - cs + cs - offset) = (offset, height - offset). Correct.
                                //    End Angle 0 (Right). Point: (offset + cs - offset, height - cs) = (cs, height - cs).
                                //    This point is inside the dock area?
                                //    (cs, height - cs). Yes.
                                //    So the fillet goes from Bottom Left (on edge) to (cs, height - cs).
                                //    It curves "in". Concave corner?
                                //    Yes, it smoothens the transition from screen edge to dock side.
                                
                                // So, to leave Bottom OPEN:
                                // Start at the end of the Right Fillet (which is on the bottom edge)
                                // OR Start at the end of the shape and go backwards?
                                // Let's just trace the path from Right to Left.
                                
                                // Right Fillet (Right Side -> Bottom Edge).
                                // Previous code: 
                                // ctx.arc(width - offset, height - cs, cs - offset, Math.PI, Math.PI / 2, true);
                                // Center (width - offset, height - cs).
                                // Start PI (Left). Point: (width - offset - (cs-offset), height - cs) = (width - cs, height - cs).
                                // End PI/2 (Bottom). Point: (width - offset, height - cs + cs - offset) = (width - offset, height - offset).
                                // This traces form Side to Bottom.
                                
                                // So let's start at the START of the Right Fillet (on the side) and go to Bottom?
                                // No, we want to Draw:
                                // Start at Bottom Right Edge -> Right Side -> Top -> Left Side -> Bottom Left Edge.
                                
                                // Start: (width - offset, height - offset). (Bottom point of Right Fillet).
                                ctx.moveTo(width - offset, height - offset);
                                
                                // Right Fillet (Bottom -> Right).
                                // Center (width - offset, height - cs).
                                // Start Angle PI/2 (Bottom). End Angle PI (Left/Side).
                                // Direction: PI/2 -> PI. Increasing. CW (false).
                                // Wait, PI/2 (Down) -> PI (Left).
                                // On Screen: Down -> Left is Clockwise. Correct.
                                ctx.arc(width - offset, height - cs, cs - offset, Math.PI / 2, Math.PI, false);
                                
                                // Now we are at (width - cs, height - cs).
                                // We need to go Up to Top Right Corner.
                                // Line to (width - cs, cs) ?
                                // Top Right Corner Radius `tr`.
                                // If tr > 0:
                                // We are going Up. Top Right Corner turns Left.
                                // We need to reach (width - cs, tr + something).
                                // Actually, standard rounded rect logic.
                                // We are at x = width - cs. We go up.
                                
                                // Let's reuse the logic but reversed? Or just trace it carefully.
                                // Line Up to start of Top Right corner.
                                // Top Right Corner center is (width - cs - tr, tr). ? No.
                                // The dock is centered? No.
                                // Previous code:
                                // Line Right: ctx.lineTo(width - cs - tr, offset);
                                // Top Right Corner: ctx.arcTo(width - cs, offset, width - cs, offset + tr, tr - offset);
                                // This implies the Right Edge of the top part is at `width - cs`.
                                
                                // So we are going UP along `x = width - cs`.
                                ctx.lineTo(width - cs, tr > 0 ? tr + offset : offset); 
                                // Wait, `tr - offset` is radius.
                                // Center of Top Right corner: (width - cs - tr, tr). 
                                // No, `tr` is the outer radius?
                                // Previous code: `ctx.arcTo(width - cs, offset, ...)`
                                // Target point 1 (corner): (width - cs, offset).
                                // Target point 2 (next): (width - cs, offset + tr).
                                // Radius: tr - offset.
                                // This creates a rounded corner at (width - cs, offset).
                                // So we approach (width - cs, offset) from left? No, previous code approached from Left.
                                // Now we approach from Bottom.
                                
                                // So:
                                // Line Up to start of TR corner.
                                ctx.lineTo(width - cs, offset + tr); // Start of corner (if tr=0, just offset)
                                
                                if (tr > 0) {
                                    // Corner from Right side to Top side.
                                    // Center (width - cs - tr, offset + tr).
                                    // Start Angle 0 (Right). End Angle 270 (Top).
                                    // Direction: 0 -> -90 (270). ACW.
                                    // ctx.arc(width - cs - tr, offset + tr, tr - offset, 0, 3 * Math.PI / 2, true);
                                    
                                    // Or use arcTo.
                                    // Current point (width - cs, offset + tr).
                                    // Control point (width - cs, offset).
                                    // End point (width - cs - tr, offset).
                                    ctx.arcTo(width - cs, offset, width - cs - tr, offset, tr - offset);
                                } else {
                                    ctx.lineTo(width - cs, offset);
                                }

                                // Line Left to start of TL corner.
                                ctx.lineTo(cs + tl, offset);
                                
                                // Top Left Corner
                                if (tl > 0) {
                                    // Control point (cs, offset).
                                    // End point (cs, offset + tl).
                                    ctx.arcTo(cs, offset, cs, offset + tl, tl - offset);
                                } else {
                                    ctx.lineTo(cs, offset);
                                }
                                
                                // Line Down to start of Left Fillet.
                                ctx.lineTo(cs, height - cs);
                                
                                // Left Fillet (Side -> Bottom).
                                // Center (offset, height - cs).
                                // Start Angle 0 (Right). End Angle PI/2 (Bottom).
                                // Direction: 0 -> 90. CW.
                                ctx.arc(offset, height - cs, cs - offset, 0, Math.PI / 2, false);
                                
                                // End point is (offset, height - offset).
                                // Done. Path is open at bottom.
                                
                            } else if (root.isLeft) {
                                // Left Edge is Open.
                                // Start at Bottom Left (end of Bottom Fillet).
                                // Bottom Fillet Center (offset, height - offset - (cs-offset))? 
                                // Let's check previous Left Dock Bottom Fillet.
                                // ctx.arc(cs, height - offset, cs - offset, 3 * Math.PI / 2, Math.PI, true);
                                // Center (cs, height - offset).
                                // Start 270 (Top). End 180 (Left). ACW.
                                // Point at 180: (cs - (cs-offset), ...) = (offset, height - offset).
                                
                                // We want to start at (offset, height - offset).
                                ctx.moveTo(offset, height - offset);
                                
                                // Bottom Fillet (Left -> Bottom).
                                // Center (cs, height - offset).
                                // Start 180 (Left). End 270 (-90) (Top).
                                // Direction: 180 -> 270. CW (false)? 
                                // Screen: Left -> Top (visually Up). 
                                // Left (180). Top (270).
                                // 180 -> 270 is ACW (increasing).
                                // Wait, visually: Left -> Up is Clockwise on screen?
                                // Center (cs, height - offset).
                                // (offset, height - offset) is Left of Center.
                                // We want to go to (cs, height - cs). This is Up-Right.
                                // (cs, height - cs) relative to center: (0, -R). Angle 270.
                                // 180 -> 270. Increasing.
                                // arc(..., 180, 270, false) ?
                                // false = Clockwise.
                                // 180 -> 270 CW goes through 0, 90? No.
                                // Canvas Default is CW.
                                // If start=PI, end=1.5PI.
                                // CW: PI -> 1.5PI. 
                                // PI (Left) -> 1.5PI (Top).
                                // Yes, Left -> Top is CW on screen coords (Y down).
                                ctx.arc(cs, height - offset, cs - offset, Math.PI, 3 * Math.PI / 2, false);
                                
                                // Now at (cs, height - cs).
                                // Line Right to Bottom Right Corner.
                                // Bottom Right corner starts at x = width - cs?
                                // No, dock width extends to right.
                                // Previous code Left Dock:
                                // Line Down: ctx.lineTo(width - offset, height - cs - br);
                                // So Right Edge is at `width - offset`.
                                
                                // Line Right
                                ctx.lineTo(width - offset - br, height - cs);
                                
                                // Bottom Right Corner
                                if (br > 0) {
                                    // Control (width - offset, height - cs).
                                    // End (width - offset, height - cs - br).
                                    ctx.arcTo(width - offset, height - cs, width - offset, height - cs - br, br - offset);
                                } else {
                                    ctx.lineTo(width - offset, height - cs);
                                }
                                
                                // Line Up
                                ctx.lineTo(width - offset, cs + tr); // wait, Top Right
                                
                                // Top Right Corner
                                if (tr > 0) {
                                    // Control (width - offset, cs).
                                    // End (width - offset - tr, cs).
                                    ctx.arcTo(width - offset, cs, width - offset - tr, cs, tr - offset);
                                } else {
                                    ctx.lineTo(width - offset, cs);
                                }
                                
                                // Line Left to Top Fillet start.
                                ctx.lineTo(cs, cs);
                                
                                // Top Fillet (Top -> Left).
                                // Center (cs, offset).
                                // Start 90 (Bottom). End 180 (Left).
                                // Wait, previous Top Fillet:
                                // ctx.arc(cs, offset, cs - offset, Math.PI, Math.PI / 2, true);
                                // Center (cs, offset).
                                // Start 180. End 90. ACW.
                                // Here we go 90 -> 180.
                                // 90 -> 180. Increasing. CW (false).
                                ctx.arc(cs, offset, cs - offset, Math.PI / 2, Math.PI, false);
                                
                                // End at (offset, offset).
                                
                            } else if (root.isRight) {
                                // Right Edge is Open.
                                // Start at Top Right (end of Top Fillet).
                                // Previous Top Fillet:
                                // ctx.arc(width - cs, offset, cs - offset, 0, Math.PI / 2, false);
                                // Center (width - cs, offset).
                                // Start 0 (Right). End 90 (Bottom). CW.
                                // Point at 0: (width - cs + R, offset) = (width - offset, offset).
                                
                                ctx.moveTo(width - offset, offset);
                                
                                // Top Fillet (Right -> Top).
                                // Center (width - cs, offset).
                                // Start 0. End 90? No.
                                // We are traversing Reverse of previous.
                                // Previous: Top Edge -> Right Edge.
                                // Now: Right Edge -> Top Edge.
                                // Start 0 (Right). End 90 (Bottom)? No.
                                // Top Edge is tangent at 90 (Bottom of circle).
                                // Wait, previous Top Fillet:
                                // "Top Fillet (Right Edge -> Top Side)"
                                // "Tangent Start: Down (0, 1)." (Angle 90? No, Angle 0 tangent is Vertical Down).
                                // "Tangent End: Left (-1, 0)." (Angle 90 tangent is Horizontal Left).
                                // So previous was 0 -> 90.
                                // Now we want 0 -> 90? No.
                                // We want Right Edge -> Top Edge.
                                // From (width - offset, offset) to (width - cs, cs).
                                // (width - offset, offset) is at Angle 0 relative to Center (width - cs, offset).
                                // (width - cs, cs) is at Angle 90 relative to Center.
                                // Path: 0 -> 90. CW.
                                // Tangent at 0: Down.
                                // Tangent at 90: Left.
                                // If we go 0 -> 90, we move Down then Left.
                                // This curves IN to the dock.
                                ctx.arc(width - cs, offset, cs - offset, 0, Math.PI / 2, false);
                                
                                // Line Left
                                ctx.lineTo(tl + offset, cs); // Top Left
                                
                                // Top Left Corner
                                if (tl > 0) {
                                    // Control (offset, cs).
                                    // End (offset, cs + tl).
                                    ctx.arcTo(offset, cs, offset, cs + tl, tl - offset);
                                } else {
                                    ctx.lineTo(offset, cs);
                                }
                                
                                // Line Down
                                ctx.lineTo(offset, height - cs - bl);
                                
                                // Bottom Left Corner
                                if (bl > 0) {
                                    // Control (offset, height - cs).
                                    // End (offset + bl, height - cs).
                                    ctx.arcTo(offset, height - cs, offset + bl, height - cs, bl - offset);
                                } else {
                                    ctx.lineTo(offset, height - cs);
                                }
                                
                                // Line Right
                                ctx.lineTo(width - cs, height - cs);
                                
                                // Bottom Fillet (Bottom -> Right).
                                // Center (width - cs, height - offset).
                                // Previous: 270 -> 0. CW.
                                // Now: Bottom Edge -> Right Edge.
                                // Tangent Right (1, 0) at 270 (Top).
                                // Tangent Up (0, -1) at 0 (Right).
                                // Wait, Bottom Fillet connects Bottom Edge to Right Edge.
                                // Point (width - cs, height - cs). Angle 270 (Top of circle).
                                // Point (width - offset, height - offset). Angle 0 (Right of circle).
                                // 270 -> 360(0). CW.
                                // Tangent at 270: Right (1, 0).
                                // Tangent at 0: Down (0, 1).
                                // Wait, we want to go Right then Down?
                                // No, we are coming from Left. We hit (width - cs, height - cs).
                                // We want to curve to (width - offset, height - offset).
                                // This is Down-Right.
                                // Tangent at 270 is Right.
                                // Tangent at 0 is Down.
                                // So 270 -> 0 is correct.
                                ctx.arc(width - cs, height - offset, cs - offset, 3 * Math.PI / 2, 2 * Math.PI, false);
                                
                                // End at (width - offset, height - offset).
                            }
                            
                            ctx.stroke();
                        }
                        
                        // Signal connections for repainting
                        Connections { target: Colors; function onPrimaryChanged() { outlineCanvas.requestPaint(); } }
                        Connections { target: Config.theme.srBg; function onBorderChanged() { outlineCanvas.requestPaint(); } }
                        Connections { target: dockBackground; function onBottomLeftRadiusChanged() { outlineCanvas.requestPaint(); } }
                        Connections { target: dockBackground; function onBottomRightRadiusChanged() { outlineCanvas.requestPaint(); } }
                        Connections { target: dockBackground; function onTopLeftRadiusChanged() { outlineCanvas.requestPaint(); } }
                        Connections { target: dockBackground; function onTopRightRadiusChanged() { outlineCanvas.requestPaint(); } }
                        Connections { target: dockContainer; function onWidthChanged() { outlineCanvas.requestPaint(); } }
                        Connections { target: dockContainer; function onHeightChanged() { outlineCanvas.requestPaint(); } }
                        Connections { target: root; function onIsDefaultChanged() { outlineCanvas.requestPaint(); } }
                        Connections { target: root; function onPositionChanged() { outlineCanvas.requestPaint(); } }
                    }
                }
            }
        }
    }
}

