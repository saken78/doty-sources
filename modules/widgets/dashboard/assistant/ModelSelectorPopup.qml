import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.modules.theme
import qs.config
import qs.modules.services
import qs.modules.components

Popup {
    id: root
    
    width: 400
    height: Math.min(contentItem.implicitHeight + 20, 500)
    
    // Center in parent
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    
    onOpened: {
        searchInput.focusInput();
        updateFilteredModels();
    }

    // Initialize fetching if empty (e.g. first run)
    Component.onCompleted: {
        if (Ai.models.length === 0) {
            Ai.fetchAvailableModels();
        }
    }

    property int selectedIndex: 0
    property var filteredModels: []
    
    function updateFilteredModels() {
        let text = searchInput.text.toLowerCase();
        let allModels = [];
        for(let i=0; i<Ai.models.length; i++) {
            allModels.push(Ai.models[i]);
        }
        
        if (text.trim() === "") {
            filteredModels = allModels;
        } else {
            filteredModels = allModels.filter(m => 
                m.name.toLowerCase().includes(text) || 
                m.api_format.toLowerCase().includes(text) ||
                m.model.toLowerCase().includes(text)
            );
        }
        
        // Reset selection if out of bounds
        if (selectedIndex >= filteredModels.length) {
            selectedIndex = Math.max(0, filteredModels.length - 1);
        }
    }

    background: StyledRect {
        variant: "popup"
        radius: Styling.radius(8)
        enableShadow: true
        border.width: 1
        border.color: Colors.outline
    }
    
    contentItem: ColumnLayout {
        spacing: 12
        
        // Search Header
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            spacing: 8
            
            SearchInput {
                id: searchInput
                Layout.fillWidth: true
                placeholderText: "Search models..."
                iconText: Icons.assistant
                
                onSearchTextChanged: text => {
                    root.updateFilteredModels();
                    root.selectedIndex = 0;
                }
                
                onDownPressed: {
                    if (root.selectedIndex < root.filteredModels.length - 1) {
                        root.selectedIndex++;
                        // Auto-scroll
                        // Note: A bit complex to scroll precisely with grouping, 
                        // but we can trust the user's "highlight" requirement is visual mostly.
                        // Ideally we'd scroll the listview.
                        modelList.positionViewAtIndex(root.selectedIndex, ListView.Contain);
                    }
                }
                
                onUpPressed: {
                    if (root.selectedIndex > 0) {
                        root.selectedIndex--;
                        modelList.positionViewAtIndex(root.selectedIndex, ListView.Contain);
                    }
                }
                
                onAccepted: {
                    if (root.filteredModels.length > 0 && root.selectedIndex >= 0) {
                         let m = root.filteredModels[root.selectedIndex];
                         Ai.setModel(m.name);
                         root.close();
                    }
                }
                
                onEscapePressed: {
                    root.close();
                }
            }
            
            // Refresh Button (Icon only)
            Button {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                flat: true
                padding: 0
                
                contentItem: Item {
                    anchors.fill: parent
                    
                    Text {
                        anchors.centerIn: parent
                        text: Icons.arrowCounterClockwise
                        font.family: Icons.font
                        font.pixelSize: 16
                        color: Colors.primary
                        visible: !Ai.fetchingModels
                    }
                    
                    // Spinner
                    Rectangle {
                        anchors.centerIn: parent
                        width: 14; height: 14
                        radius: 7
                        color: "transparent"
                        border.width: 2
                        border.color: Colors.primary
                        visible: Ai.fetchingModels
                        
                        Rectangle {
                            width: 6; height: 6
                            radius: 3
                            color: Colors.surface
                            x: -1; y: -1
                        }
                        
                        RotationAnimation on rotation {
                            loops: Animation.Infinite
                            from: 0; to: 360
                            duration: 1000
                            running: Ai.fetchingModels
                        }
                    }
                }
                
                background: StyledRect {
                    variant: parent.hovered ? "focus" : "transparent"
                    radius: Styling.radius(4)
                }
                
                onClicked: Ai.fetchAvailableModels()
            }
        }
        
        Separator { Layout.fillWidth: true; vert: false }
        
        // Model List
        ListView {
            id: modelList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: Math.min(contentHeight, 400)
            clip: true
            
            model: root.filteredModels
            
            // Note: Grouping complicates index-based navigation significantly.
            // For true keyboard nav over a filtered list, flat list is often better UX.
            // User requested "SearchInput to filter models", so flatness is expected.
            // We can show the "provider" as a subtitle or badge instead of sections.
            
            delegate: Button {
                id: delegateBtn
                width: modelList.width
                height: 48
                flat: true
                leftPadding: 8
                rightPadding: 8
                
                property bool isSelected: index === root.selectedIndex
                property bool isActiveModel: Ai.currentModel.name === modelData.name

                contentItem: RowLayout {
                    anchors.fill: parent
                    spacing: 12
                    
                    // Icon
                    Item {
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        
                       Text {
                            anchors.centerIn: parent
                            text: {
                                switch(modelData.icon) {
                                    case "sparkles": return Icons.sparkle;
                                    case "openai": return Icons.lightning;
                                    case "wind": return Icons.sparkle; 
                                    default: return Icons.robot;
                                }
                            }
                            font.family: Icons.font
                            font.pixelSize: 20
                            color: delegateBtn.isSelected ? Config.resolveColor(Config.theme.srPrimary.itemColor) : (delegateBtn.isActiveModel ? Colors.primary : Colors.overSurface)
                            
                            Behavior on color {
                                enabled: Config.animDuration > 0
                                ColorAnimation { duration: Config.animDuration / 2; easing.type: Easing.OutCubic }
                            }
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        
                        Text {
                            text: modelData.name
                            color: delegateBtn.isSelected ? Config.resolveColor(Config.theme.srPrimary.itemColor) : (delegateBtn.isActiveModel ? Colors.primary : Colors.overBackground)
                            font.family: Config.theme.font
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            
                            Behavior on color {
                                enabled: Config.animDuration > 0
                                ColorAnimation { duration: Config.animDuration / 2; easing.type: Easing.OutCubic }
                            }
                        }
                        
                        Text {
                            // Show provider and model ID
                            text: modelData.api_format.toUpperCase() + " • " + modelData.model
                            color: delegateBtn.isSelected ? Config.resolveColor(Config.theme.srPrimary.itemColor) : Colors.outline
                            font.family: Config.theme.font
                            font.pixelSize: 11
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            
                            Behavior on color {
                                enabled: Config.animDuration > 0
                                ColorAnimation { duration: Config.animDuration / 2; easing.type: Easing.OutCubic }
                            }
                        }
                    }
                    
                    // Active Check
                    Text {
                        text: Icons.accept
                        font.family: Icons.font
                        font.pixelSize: 16
                        color: Colors.primary
                        visible: delegateBtn.isActiveModel
                    }
                }
                
                background: Rectangle {
                   color: "transparent"
                   
                   // Hover/Selection Highlight
                   Rectangle {
                       anchors.fill: parent
                       color: Colors.surface
                       visible: delegateBtn.isSelected || delegateBtn.hovered
                       opacity: 0.5
                       radius: Styling.radius(4)
                   }
                }
                
                onClicked: {
                    Ai.setModel(modelData.name);
                    root.close();
                }
                
                // Mouse hover updates selection
                MouseArea {
                    anchors.fill: parent
                    onEntered: root.selectedIndex = index
                    propagateComposedEvents: true
                    onClicked: mouse => mouse.accepted = false // Pass to Button
                }
            }
        }
    }
}
