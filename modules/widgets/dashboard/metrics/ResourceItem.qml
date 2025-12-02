pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.modules.theme
import qs.config

Item {
    id: root

    property string icon: ""
    property string label: ""
    property real value: 0.0
    property color barColor: Colors.primary

    implicitHeight: contentColumn.height

    Column {
        id: contentColumn
        width: parent.width
        spacing: 4

        // Icon and label
        Row {
            width: parent.width
            spacing: 6

            Text {
                text: root.icon
                font.family: Icons.font
                font.pixelSize: 16
                color: Colors.overBackground
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: root.label
                font.family: Config.theme.font
                font.pixelSize: 12
                font.weight: Font.Medium
                color: Colors.overSurfaceVariant
                anchors.verticalCenter: parent.verticalCenter
                elide: Text.ElideRight
                width: parent.width - 28
            }
        }

        // Progress bar
        Rectangle {
            width: parent.width
            height: 6
            radius: Styling.radius(1)
            color: Colors.surfaceDim

            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, root.value))
                height: parent.height
                radius: parent.radius
                color: root.barColor

                Behavior on width {
                    enabled: Config.animDuration > 0
                    NumberAnimation {
                        duration: Config.animDuration
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        // Percentage text
        Text {
            width: parent.width
            text: `${Math.round(root.value * 100)}%`
            font.family: Config.theme.font
            font.pixelSize: 11
            font.weight: Font.Normal
            color: Colors.overSurfaceVariant
            horizontalAlignment: Text.AlignRight
        }
    }
}
