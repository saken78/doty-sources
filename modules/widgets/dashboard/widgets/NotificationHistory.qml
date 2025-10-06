import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.modules.theme
import qs.modules.services
import qs.modules.notifications
import qs.config

ClippingRectangle {
    color: Colors.surface
    radius: Config.roundness > 0 ? Config.roundness + 4 : 0
    clip: true

    ScrollView {
        anchors.fill: parent
        anchors.margins: 4

        ListView {
            id: notificationList
            spacing: 4
            model: Notifications.appNameList

            delegate: NotificationGroup {
                required property int index
                required property string modelData
                width: notificationList.width
                notificationGroup: Notifications.groupsByAppName[modelData]
                expanded: false
                popup: false
            }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 16
        visible: Notifications.appNameList.length === 0

        Text {
            text: Icons.bellZ
            textFormat: Text.RichText
            font.family: Icons.font
            font.pixelSize: 64
            color: Colors.surfaceBright
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
