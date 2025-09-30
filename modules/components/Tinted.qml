pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import qs.modules.theme
import qs.config

Item {
    property var sourceItem: null  // The icon item to tint

    Loader {
        active: Config.tintIcons
        anchors.fill: parent
        sourceComponent: MultiEffect {
            source: sourceItem
            saturation: -0.25
            colorization: 0.25
            colorizationColor: Colors.primary
        }
    }
}
