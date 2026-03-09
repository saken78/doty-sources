import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs.modules.globals
import qs.modules.theme
import qs.modules.services
import qs.modules.components

PanelWindow {
    id: quotesPopup

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    readonly property var screenVisibilities: Visibilities.getForScreen(screen.name)
    readonly property bool quotesOpen: screenVisibilities ? screenVisibilities.quotes : false

    visible: quotesOpen
    exclusionMode: ExclusionMode.Ignore

    mask: Region {
        item: quotesOpen ? fullMask : emptyMask
    }

    Item {
        anchors.fill: parent

        Rectangle {
            id: background
            anchors.centerIn: parent
            width: 400
            height: 150
            radius: 20
            color: Config.theme.colors.surface
            border.color: Config.theme.colors.outline
            border.width: 1
        }

        Text {
            anchors.centerIn: background
            width: background.width - 40
            horizontalAlignment: Text.AlignHCenter
            text: "Disconnect your brain and do it"
            font.pixelSize: 18
            font.styleName: "Italic"
            color: Config.theme.colors.onSurface
            wrapMode: Text.WordWrap
        }
    }
}
