import QtQuick
import QtQuick.Effects
import qs.modules.theme
import qs.config

Rectangle {
    color: Colors.adapter.surfaceContainer
    radius: Config.roundness
    border.color: Colors.adapter.surfaceBright
    border.width: 0

    layer.enabled: false
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 0
        shadowBlur: 1
        shadowColor: Colors.adapter.shadow
        shadowOpacity: 0.5
    }
}
