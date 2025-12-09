pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.theme
import qs.modules.components
import qs.modules.services
import qs.config

Rectangle {
    id: root
    color: "transparent"
    implicitWidth: 400
    implicitHeight: 300

    property int currentSection: 0  // 0: Network, 1: Bluetooth, 2: Mixer, 3: Effects

    RowLayout {
        anchors.fill: parent
        spacing: 8

        // Sidebar navigation with labels
        ColumnLayout {
            id: sidebar
            Layout.preferredWidth: 100
            Layout.maximumWidth: 100
            Layout.fillHeight: true
            Layout.fillWidth: false
            spacing: 4

            Repeater {
                model: [
                    { icon: Icons.wifiHigh, label: "Network", section: 0 },
                    { icon: Icons.bluetooth, label: "Bluetooth", section: 1 },
                    { icon: Icons.faders, label: "Mixer", section: 2 },
                    { icon: Icons.waveform, label: "Effects", section: 3 }
                ]

                delegate: Button {
                    id: sidebarButton
                    required property var modelData
                    required property int index

                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    flat: true
                    hoverEnabled: true

                    background: StyledRect {
                        variant: root.currentSection === sidebarButton.modelData.section ? "primary" : (sidebarButton.hovered ? "focus" : "common")
                        radius: Styling.radius(4)
                    }

                    contentItem: RowLayout {
                        spacing: 8

                        Text {
                            text: sidebarButton.modelData.icon
                            font.family: Icons.font
                            font.pixelSize: 16
                            color: root.currentSection === sidebarButton.modelData.section 
                                ? Config.resolveColor(Config.theme.srPrimary.itemColor) 
                                : Colors.overBackground
                            Layout.leftMargin: 8

                            Behavior on color {
                                enabled: Config.animDuration > 0
                                ColorAnimation {
                                    duration: Config.animDuration
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }

                        Text {
                            text: sidebarButton.modelData.label
                            font.family: Config.theme.font
                            font.pixelSize: Config.theme.fontSize - 2
                            font.weight: Font.Medium
                            color: root.currentSection === sidebarButton.modelData.section 
                                ? Config.resolveColor(Config.theme.srPrimary.itemColor) 
                                : Colors.overBackground
                            Layout.fillWidth: true
                            elide: Text.ElideRight

                            Behavior on color {
                                enabled: Config.animDuration > 0
                                ColorAnimation {
                                    duration: Config.animDuration
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }

                    onClicked: root.currentSection = sidebarButton.modelData.section

                    StyledToolTip {
                        visible: sidebarButton.hovered
                        tooltipText: sidebarButton.modelData.label
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // Scroll hint for sidebar
            WheelHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onWheel: event => {
                    if (event.angleDelta.y > 0 && root.currentSection > 0) {
                        root.currentSection--;
                    } else if (event.angleDelta.y < 0 && root.currentSection < 3) {
                        root.currentSection++;
                    }
                }
            }
        }

        // Separator
        Separator {
            Layout.preferredWidth: 2
            Layout.fillHeight: true
            vert: true
        }

        // Content area with animated transitions
        Item {
            id: contentArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 300
            Layout.preferredWidth: 300
            clip: true

            property int previousSection: 0

            // Track section changes for animation direction
            onVisibleChanged: {
                if (visible) {
                    contentArea.previousSection = root.currentSection;
                }
            }

            Connections {
                target: root
                function onCurrentSectionChanged() {
                    contentArea.previousSection = root.currentSection;
                }
            }

            // WiFi Panel
            WifiPanel {
                id: wifiPanel
                anchors.fill: parent
                visible: opacity > 0
                opacity: root.currentSection === 0 ? 1 : 0

                Behavior on opacity {
                    enabled: Config.animDuration > 0
                    NumberAnimation {
                        duration: Config.animDuration
                        easing.type: Easing.OutCubic
                    }
                }

                transform: Translate {
                    x: root.currentSection === 0 ? 0 : (root.currentSection > 0 ? -20 : 20)

                    Behavior on x {
                        enabled: Config.animDuration > 0
                        NumberAnimation {
                            duration: Config.animDuration
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            // Bluetooth Panel
            BluetoothPanel {
                id: bluetoothPanel
                anchors.fill: parent
                visible: opacity > 0
                opacity: root.currentSection === 1 ? 1 : 0

                Behavior on opacity {
                    enabled: Config.animDuration > 0
                    NumberAnimation {
                        duration: Config.animDuration
                        easing.type: Easing.OutCubic
                    }
                }

                transform: Translate {
                    x: root.currentSection === 1 ? 0 : (root.currentSection > 1 ? -20 : 20)

                    Behavior on x {
                        enabled: Config.animDuration > 0
                        NumberAnimation {
                            duration: Config.animDuration
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            // Audio Mixer Panel
            AudioMixerPanel {
                id: audioPanel
                anchors.fill: parent
                visible: opacity > 0
                opacity: root.currentSection === 2 ? 1 : 0

                Behavior on opacity {
                    enabled: Config.animDuration > 0
                    NumberAnimation {
                        duration: Config.animDuration
                        easing.type: Easing.OutCubic
                    }
                }

                transform: Translate {
                    x: root.currentSection === 2 ? 0 : (root.currentSection > 2 ? -20 : 20)

                    Behavior on x {
                        enabled: Config.animDuration > 0
                        NumberAnimation {
                            duration: Config.animDuration
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            // EasyEffects Panel
            EasyEffectsPanel {
                id: effectsPanel
                anchors.fill: parent
                visible: opacity > 0
                opacity: root.currentSection === 3 ? 1 : 0

                Behavior on opacity {
                    enabled: Config.animDuration > 0
                    NumberAnimation {
                        duration: Config.animDuration
                        easing.type: Easing.OutCubic
                    }
                }

                transform: Translate {
                    x: root.currentSection === 3 ? 0 : (root.currentSection > 3 ? -20 : 20)

                    Behavior on x {
                        enabled: Config.animDuration > 0
                        NumberAnimation {
                            duration: Config.animDuration
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }
}
