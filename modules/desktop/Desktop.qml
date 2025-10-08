import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.modules.desktop
import qs.modules.services
import qs.config

PanelWindow {
    id: desktop

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    color: "transparent"

    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "quickshell:desktop"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    visible: Config.desktop.enabled

    GridView {
        id: gridView
        anchors.fill: parent
        anchors.leftMargin: Config.desktop.spacing
        anchors.rightMargin: Config.desktop.spacing

        cellWidth: Config.desktop.iconSize + Config.desktop.spacing
        cellHeight: {
            var minSpacing = 32;
            var iconHeight = Config.desktop.iconSize + 40;
            var availableHeight = parent.height;
            
            var maxRows = Math.floor(availableHeight / (iconHeight + minSpacing));
            if (maxRows < 1) maxRows = 1;
            
            return availableHeight / maxRows;
        }

        model: DesktopService.items

        flow: GridView.FlowTopToBottom

        delegate: DesktopIcon {
            required property string name
            required property string path
            required property string type
            required property string icon
            required property bool isDesktopFile

            itemName: name
            itemPath: path
            itemType: type
            itemIcon: icon

            onActivated: {
                console.log("Activated:", itemName);
            }

            onContextMenuRequested: {
                console.log("Context menu requested for:", itemName);
            }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: 200
        height: 60
        color: Qt.rgba(0, 0, 0, 0.7)
        radius: Config.roundness
        visible: !DesktopService.initialLoadComplete

        Text {
            anchors.centerIn: parent
            text: "Loading desktop..."
            color: "white"
            font.family: Config.defaultFont
            font.pixelSize: Config.theme.fontSize
        }
    }
}
