pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.modules.theme
import qs.modules.components
import qs.modules.services
import qs.config

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // Header with title and bypass toggle
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            spacing: 8

            Text {
                text: "EasyEffects"
                font.family: Config.theme.font
                font.pixelSize: Config.theme.fontSize + 2
                font.weight: Font.Medium
                color: Colors.overBackground
            }

            Item { Layout.fillWidth: true }

            // Status indicator
            Text {
                visible: EasyEffectsService.bypassed
                text: "Bypassed"
                font.family: Config.theme.font
                font.pixelSize: Config.theme.fontSize - 2
                color: Colors.error
            }

            // Bypass toggle switch
            Switch {
                id: bypassToggle
                checked: !EasyEffectsService.bypassed
                onCheckedChanged: {
                    if (checked !== !EasyEffectsService.bypassed) {
                        EasyEffectsService.setBypass(!checked);
                    }
                }

                indicator: Rectangle {
                    implicitWidth: 40
                    implicitHeight: 20
                    x: bypassToggle.leftPadding
                    y: parent.height / 2 - height / 2
                    radius: height / 2
                    color: bypassToggle.checked ? Colors.primary : Colors.surfaceBright
                    border.color: bypassToggle.checked ? Colors.primary : Colors.outline

                    Behavior on color {
                        enabled: Config.animDuration > 0
                        ColorAnimation { duration: Config.animDuration / 2 }
                    }

                    Rectangle {
                        x: bypassToggle.checked ? parent.width - width - 2 : 2
                        y: 2
                        width: parent.height - 4
                        height: width
                        radius: width / 2
                        color: bypassToggle.checked ? Colors.background : Colors.overSurfaceVariant

                        Behavior on x {
                            enabled: Config.animDuration > 0
                            NumberAnimation { duration: Config.animDuration / 2; easing.type: Easing.OutCubic }
                        }
                    }
                }
                background: null

                StyledToolTip {
                    visible: bypassToggle.hovered
                    text: bypassToggle.checked ? "Effects enabled" : "Effects bypassed"
                }
            }
        }

        // Not available state
        Text {
            visible: !EasyEffectsService.available
            text: "EasyEffects not installed"
            font.family: Config.theme.font
            font.pixelSize: Config.theme.fontSize
            color: Colors.overSurfaceVariant
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 32
        }

        // Presets section
        Flickable {
            visible: EasyEffectsService.available
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: presetsColumn.implicitHeight
            clip: true

            ColumnLayout {
                id: presetsColumn
                width: parent.width
                spacing: 12

                // Output presets
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    visible: EasyEffectsService.outputPresets.length > 0

                    Text {
                        text: "Output Presets"
                        font.family: Config.theme.font
                        font.pixelSize: Config.theme.fontSize - 1
                        font.weight: Font.Medium
                        color: Colors.overSurfaceVariant
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: 6

                        Repeater {
                            model: EasyEffectsService.outputPresets

                            delegate: Button {
                                id: presetButton
                                required property string modelData
                                flat: true
                                
                                property bool isActive: EasyEffectsService.activeOutputPreset === modelData

                                background: StyledRect {
                                    variant: presetButton.isActive ? "primary" : (presetButton.hovered ? "focus" : "common")
                                    radius: Styling.radius(4)
                                }

                                contentItem: Text {
                                    text: presetButton.modelData
                                    font.family: Config.theme.font
                                    font.pixelSize: Config.theme.fontSize - 1
                                    color: presetButton.isActive 
                                        ? Config.resolveColor(Config.theme.srPrimary.itemColor)
                                        : Colors.overBackground
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 12
                                    rightPadding: 12
                                    topPadding: 6
                                    bottomPadding: 6
                                }

                                onClicked: EasyEffectsService.loadPreset(modelData)
                            }
                        }
                    }
                }

                // Input presets
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    visible: EasyEffectsService.inputPresets.length > 0

                    Text {
                        text: "Input Presets"
                        font.family: Config.theme.font
                        font.pixelSize: Config.theme.fontSize - 1
                        font.weight: Font.Medium
                        color: Colors.overSurfaceVariant
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: 6

                        Repeater {
                            model: EasyEffectsService.inputPresets

                            delegate: Button {
                                id: inputPresetButton
                                required property string modelData
                                flat: true
                                
                                property bool isActive: EasyEffectsService.activeInputPreset === modelData

                                background: StyledRect {
                                    variant: inputPresetButton.isActive ? "primary" : (inputPresetButton.hovered ? "focus" : "common")
                                    radius: Styling.radius(4)
                                }

                                contentItem: Text {
                                    text: inputPresetButton.modelData
                                    font.family: Config.theme.font
                                    font.pixelSize: Config.theme.fontSize - 1
                                    color: inputPresetButton.isActive 
                                        ? Config.resolveColor(Config.theme.srPrimary.itemColor)
                                        : Colors.overBackground
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 12
                                    rightPadding: 12
                                    topPadding: 6
                                    bottomPadding: 6
                                }

                                onClicked: EasyEffectsService.loadPreset(modelData)
                            }
                        }
                    }
                }

                // Empty state
                Text {
                    visible: EasyEffectsService.outputPresets.length === 0 && EasyEffectsService.inputPresets.length === 0
                    text: "No presets configured"
                    font.family: Config.theme.font
                    font.pixelSize: Config.theme.fontSize
                    color: Colors.overSurfaceVariant
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 16
                }

                // Current status
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 16
                    spacing: 4
                    visible: EasyEffectsService.activeOutputPreset || EasyEffectsService.activeInputPreset

                    Text {
                        text: "Active"
                        font.family: Config.theme.font
                        font.pixelSize: Config.theme.fontSize - 1
                        font.weight: Font.Medium
                        color: Colors.overSurfaceVariant
                    }

                    RowLayout {
                        spacing: 16
                        visible: EasyEffectsService.activeOutputPreset

                        Text {
                            text: Icons.speakerHigh
                            font.family: Icons.font
                            font.pixelSize: 14
                            color: Colors.primary
                        }
                        Text {
                            text: EasyEffectsService.activeOutputPreset
                            font.family: Config.theme.font
                            font.pixelSize: Config.theme.fontSize - 1
                            color: Colors.overBackground
                        }
                    }

                    RowLayout {
                        spacing: 16
                        visible: EasyEffectsService.activeInputPreset

                        Text {
                            text: Icons.mic
                            font.family: Icons.font
                            font.pixelSize: 14
                            color: Colors.primary
                        }
                        Text {
                            text: EasyEffectsService.activeInputPreset
                            font.family: Config.theme.font
                            font.pixelSize: Config.theme.fontSize - 1
                            color: Colors.overBackground
                        }
                    }
                }
            }
        }

        // Footer with open app button
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            spacing: 8
            visible: EasyEffectsService.available

            Item { Layout.fillWidth: true }

            // Open EasyEffects button
            Button {
                id: openButton
                flat: true
                implicitWidth: 32
                implicitHeight: 32

                background: StyledRect {
                    variant: openButton.hovered ? "focus" : "common"
                    radius: Styling.radius(4)
                }

                contentItem: Text {
                    text: Icons.externalLink
                    font.family: Icons.font
                    font.pixelSize: 16
                    color: Colors.overBackground
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: EasyEffectsService.openApp()

                StyledToolTip {
                    visible: openButton.hovered
                    text: "Open EasyEffects"
                }
            }

            // Refresh button
            Button {
                id: refreshButton
                flat: true
                implicitWidth: 32
                implicitHeight: 32

                background: StyledRect {
                    variant: refreshButton.hovered ? "focus" : "common"
                    radius: Styling.radius(4)
                }

                contentItem: Text {
                    text: Icons.sync
                    font.family: Icons.font
                    font.pixelSize: 16
                    color: Colors.overBackground
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: EasyEffectsService.refresh()

                StyledToolTip {
                    visible: refreshButton.hovered
                    text: "Refresh"
                }
            }
        }
    }
}
