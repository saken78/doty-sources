pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.modules.services
import qs.modules.components
import qs.modules.theme
import qs.config

Item {
    id: root
    required property var bar
    property bool vertical: bar.orientation === "vertical"
    property bool isHovered: false
    property bool layerEnabled: true
    property real startRadius: 0
    property real endRadius: 0
    property bool popupOpen: false

    implicitWidth: vertical ? 36 : rowLayout.implicitWidth + 26
    implicitHeight: 36

    HoverHandler {
        onHoveredChanged: root.isHovered = hovered
    }

    StyledRect {
        id: buttonBg
        variant: root.popupOpen ? "primary" : "bg"
        anchors.fill: parent
        enableShadow: root.layerEnabled
        topLeftRadius: root.startRadius
        topRightRadius: root.endRadius
        bottomLeftRadius: root.startRadius
        bottomRightRadius: root.endRadius

        Rectangle {
            anchors.fill: parent
            color: Styling.srItem("overprimary")
            opacity: root.isHovered ? 0.15 : 0
            radius: parent.radius ?? 0
            Behavior on opacity {
                enabled: Config.animDuration > 0
                NumberAnimation {
                    duration: Config.animDuration / 2
                }
            }
        }

        RowLayout {
            id: rowLayout
            anchors.centerIn: parent
            spacing: 6

            Text {
                text: Icons.ram
                font.family: Icons.font
                font.pixelSize: 18
                color: Styling.srItem("overprimary")
            }

            // Text {
            //     text: Math.round(SystemResources.ramUsage) + "%"
            //     font.family: Config.theme.font
            //     font.pixelSize: Config.theme.fontSize
            //     font.weight: Font.Bold
            //     horizontalAlignment: Text.AlignHCenter
            //     color: Colors.overBackground
            // }

            // RAM
            Text {
                text: {
                    const used = (SystemResources.ramUsed / 1024 / 1024).toFixed(1);
                    const total = (SystemResources.ramTotal / 1024 / 1024).toFixed(0);
                    return used + "/" + total + "G";
                }
                font.family: Config.theme.font
                font.pixelSize: Config.theme.fontSize
                font.weight: Font.Bold
                color: Colors.overBackground
                horizontalAlignment: Text.AlignHCenter
            }

            Separator {
                id: separator
                vert: true
            }

            // CPU
            Text {
                text: Icons.cpu
                font.family: Icons.font
                font.pixelSize: 18
                color: Styling.srItem("overprimary")
            }

            // Separator {
            //     Layout.preferredHeight: 2
            //     Layout.fillWidth: true
            // }

            Text {
                text: `${Math.round(SystemResources.cpuUsage)}%`
                font.family: Config.theme.font
                font.pixelSize: Config.theme.fontSize
                font.weight: Font.Bold
                color: Colors.overBackground
            }

            Separator {
                vert: true
            }

            Text {
                visible: SystemResources.cpuTemp >= 0
                text: Icons.temperature
                font.family: Icons.font
                font.pixelSize: Config.theme.fontSize
                color: Colors.red
            }

            Text {
                visible: SystemResources.cpuTemp >= 0
                text: `${SystemResources.cpuTemp}°`
                font.family: Config.theme.font
                font.pixelSize: Config.theme.fontSize
                font.weight: Font.Bold
                color: Colors.overBackground
            }
        }
    }
}
