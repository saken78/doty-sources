import QtQuick
import QtQuick.Layouts
import qs.modules.theme
import qs.config

Item {
    id: root

    property real value: 0
    property color accentColor: Colors.primary
    property color trackColor: Colors.outline
    property real lineWidth: 4
    property real ringPadding: 6
    property bool enabled: true
    readonly property bool isDragging: mouseArea.isDragging

    signal valueEdited(real newValue)
    signal draggingChanged(bool dragging)

    width: 200
    height: 200

    property real startAngleDeg: 180 // 9 o'clock
    property real spanAngleDeg: 180 // Half circle clockwise to 3 o'clock

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: root.enabled
        preventStealing: true

        property bool isDragging: false

        function updateValueFromMouse(mouseX, mouseY) {
            let centerX = width / 2;
            let centerY = height / 2;
            
            // Calculate angle in radians
            let angle = Math.atan2(mouseY - centerY, mouseX - centerX);
            
            // Normalize angle to [0, 2*PI) starting from 0 (3 o'clock)
            if (angle < 0) angle += 2 * Math.PI;

            // Convert inputs to radians
            let startRad = root.startAngleDeg * Math.PI / 180;
            let spanRad = root.spanAngleDeg * Math.PI / 180;

            // We need to map the mouse angle to our span.
            // Problem: Canvas angles can wrap. 180 to 360 is continuous.
            // But what if start is 270 and span is 180 (270 -> 90)?
            // Let's assume standard use case: 180 (left) -> 360 (right).
            
            // Shift angle so start is at 0
            // BUT, if we are in the "dead zone" (bottom half), we need to clamp.
            
            // Simple approach for 180->360 (Top Half):
            // 3 o'clock = 0/360. 9 o'clock = 180.
            // Mouse angle goes 0..PI..2PI.
            // We want inputs from PI to 2PI.
            // If angle is between 0 and PI (bottom half), we clamp to nearest end.
            
            let relativeAngle = angle - startRad;
            // Normalize relative angle
            while (relativeAngle < 0) relativeAngle += 2 * Math.PI;
            
            // If the angle is within the span, use it.
            // If it's outside, clamp to 0 or span.
            // This 'outside' is the dead zone (360 - span).
            
            let progress = 0;
            
            if (relativeAngle <= spanRad) {
                progress = relativeAngle / spanRad;
            } else {
                // Closer to start or end?
                // The "end" of the active arc is at `spanRad`. 
                // The "start" is at 0 (relative).
                // Distance to end: relativeAngle - spanRad
                // Distance to start (wrap around): 2*PI - relativeAngle
                
                let distToEnd = relativeAngle - spanRad;
                let distToStart = 2 * Math.PI - relativeAngle;
                
                if (distToEnd < distToStart) {
                    progress = 1.0;
                } else {
                    progress = 0.0;
                }
            }
            
            root.valueEdited(progress);
        }

        onPressed: mouse => {
            isDragging = true;
            root.draggingChanged(true);
            updateValueFromMouse(mouse.x, mouse.y);
        }

        onPositionChanged: mouse => {
            if (isDragging) {
                updateValueFromMouse(mouse.x, mouse.y);
            }
        }

        onReleased: {
            if (isDragging) {
                isDragging = false;
                root.draggingChanged(false);
            }
        }
    }

    Item {
        id: progressCanvas
        anchors.centerIn: parent
        anchors.fill: parent

        property real progress: root.value

        Canvas {
            id: canvas
            anchors.fill: parent
            antialiasing: true

            onPaint: {
                let ctx = getContext("2d");
                ctx.reset();

                let centerX = width / 2;
                let centerY = height / 2;
                let radius = (Math.min(width, height) / 2) - root.lineWidth / 2;
                let lineWidth = root.lineWidth;

                ctx.lineCap = "round";

                let startRad = root.startAngleDeg * Math.PI / 180;
                let spanRad = root.spanAngleDeg * Math.PI / 180;
                let currentSpan = spanRad * progressCanvas.progress;

                // Draw track (full span)
                ctx.strokeStyle = root.trackColor;
                ctx.lineWidth = lineWidth;
                ctx.beginPath();
                ctx.arc(centerX, centerY, radius, startRad, startRad + spanRad, false);
                ctx.stroke();

                // Draw progress
                if (progressCanvas.progress > 0) {
                    ctx.strokeStyle = root.accentColor;
                    ctx.lineWidth = lineWidth;
                    ctx.beginPath();
                    ctx.arc(centerX, centerY, radius, startRad, startRad + currentSpan, false);
                    ctx.stroke();
                }

                // Draw handle (small dot at current position)
                if (root.enabled) {
                    let handleAngle = startRad + currentSpan;
                    let handleX = centerX + radius * Math.cos(handleAngle);
                    let handleY = centerY + radius * Math.sin(handleAngle);

                    ctx.fillStyle = Colors.overBackground;
                    ctx.beginPath();
                    ctx.arc(handleX, handleY, lineWidth * 1.5, 0, 2 * Math.PI);
                    ctx.fill();
                }
            }
            
            Connections {
                target: progressCanvas
                function onProgressChanged() {
                    canvas.requestPaint();
                }
            }

            Connections {
                target: root
                function onAccentColorChanged() {
                    canvas.requestPaint();
                }
                function onValueEdited() {
                     // Force repaint even if root.value didn't change (e.g. click in same spot)
                     canvas.requestPaint();
                }
            }
        }

        Behavior on progress {
            enabled: Config.animDuration > 0 && !root.isDragging
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }
}
