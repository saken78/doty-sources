pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import qs.modules.theme
import qs.config

Rectangle {
    id: root

    required property string variant

    property string gradientOrientation: "vertical"
    property bool enableShadow: false

    readonly property var gradientStops: {
        switch (variant) {
            case "bg": return Config.theme.gradBg
            case "pane": return Config.theme.gradPane
            case "common": return Config.theme.gradCommon
            case "focus": return Config.theme.gradFocus
            case "active": return Config.theme.gradActive
            case "activefocus": return Config.theme.gradActiveFocus
            default: return Config.theme.gradCommon
        }
    }

    readonly property var borderData: {
        switch (variant) {
            case "bg": return Config.theme.borderBg
            case "pane": return Config.theme.borderPane
            case "common": return Config.theme.borderCommon
            case "focus": return Config.theme.borderFocus
            case "active": return Config.theme.borderActive
            case "activefocus": return Config.theme.borderActiveFocus
            default: return Config.theme.borderCommon
        }
    }

    readonly property color itemColor: {
        switch (variant) {
            case "bg": return Config.resolveColor(Config.theme.itemBg)
            case "pane": return Config.resolveColor(Config.theme.itemPane)
            case "common": return Config.resolveColor(Config.theme.itemCommon)
            case "focus": return Config.resolveColor(Config.theme.itemFocus)
            case "active": return Config.resolveColor(Config.theme.itemActive)
            case "activefocus": return Config.resolveColor(Config.theme.itemActiveFocus)
            default: return Config.resolveColor(Config.theme.itemCommon)
        }
    }

    radius: Config.roundness
    border.color: Config.resolveColor(borderData[0])
    border.width: borderData[1]

    gradient: Gradient {
        orientation: gradientOrientation === "horizontal" ? Gradient.Horizontal : Gradient.Vertical

        GradientStop {
            property var stopData: gradientStops[0] || ["surface", 0.0]
            position: stopData[1]
            color: Config.resolveColor(stopData[0])
        }

        GradientStop {
            property var stopData: gradientStops[1] || gradientStops[gradientStops.length - 1]
            position: stopData[1]
            color: Config.resolveColor(stopData[0])
        }

        GradientStop {
            property var stopData: gradientStops[2] || gradientStops[gradientStops.length - 1]
            position: stopData[1]
            color: Config.resolveColor(stopData[0])
        }

        GradientStop {
            property var stopData: gradientStops[3] || gradientStops[gradientStops.length - 1]
            position: stopData[1]
            color: Config.resolveColor(stopData[0])
        }

        GradientStop {
            property var stopData: gradientStops[4] || gradientStops[gradientStops.length - 1]
            position: stopData[1]
            color: Config.resolveColor(stopData[0])
        }
    }

    layer.enabled: enableShadow
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowHorizontalOffset: Config.theme.shadowXOffset
        shadowVerticalOffset: Config.theme.shadowYOffset
        shadowBlur: Config.theme.shadowBlur
        shadowColor: Config.resolveColor(Config.theme.shadowColor)
        shadowOpacity: Config.theme.shadowOpacity
    }
}
