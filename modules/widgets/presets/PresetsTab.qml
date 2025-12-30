import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.modules.theme
import qs.modules.components
import qs.modules.globals
import qs.modules.services
import qs.config

Item {
    id: root
    focus: true

    property string searchText: ""
    property int selectedIndex: -1
    property var presets: []
    
    // Active preset (from persistent storage)
    readonly property string activePreset: PresetsService.activePreset

    // Create mode state
    property bool createMode: false
    property string presetNameToCreate: ""
    property var selectedConfigFiles: availableConfigFiles.slice()

    // Available config files
    readonly property var availableConfigFiles: [
        "ai.js", "bar.js", "desktop.js", "dock.js", "hyprland.js",
        "lockscreen.js", "notch.js", "overview.js", "performance.js",
        "prefix.js", "system.js", "theme.js", "weather.js", "workspaces.js"
    ]

    // List model
    ListModel {
        id: presetsModel
    }

    property alias flickable: resultsList
    property bool needsScrollbar: resultsList.contentHeight > resultsList.height
    property bool isManualScrolling: false
    
    // Reset state when opening
    function resetSearch() {
        searchText = "";
        selectedIndex = -1;
        createMode = false;
        presetNameToCreate = "";
        searchInput.focusInput();
        updateFilteredPresets();
    }

    function focusSearchInput() {
        searchInput.focusInput();
    }

    function updateFilteredPresets() {
        var newFilteredPresets = [];
        var createButtonText = "Create new preset";
        var isCreateSpecific = false;
        var nameToCreate = "";

        if (searchText.length === 0) {
            newFilteredPresets = presets.slice();
        } else {
            newFilteredPresets = presets.filter(function (preset) {
                return preset.name.toLowerCase().includes(searchText.toLowerCase());
            });

            // If strict match not found, offer creation
            let exactMatch = presets.find(p => p.name.toLowerCase() === searchText.toLowerCase());
            if (!exactMatch && searchText.length > 0) {
                createButtonText = `Create preset "${searchText}"`;
                isCreateSpecific = true;
                nameToCreate = searchText;
            }
        }

        // Add create button at top
        newFilteredPresets.unshift({
            name: createButtonText,
            isCreateButton: !isCreateSpecific,
            isCreateSpecificButton: isCreateSpecific,
            presetNameToCreate: nameToCreate,
            configFiles: [],
            icon: "plus"
        });

        // Update model
        presetsModel.clear();
        for (var i = 0; i < newFilteredPresets.length; i++) {
            presetsModel.append({
                presetId: newFilteredPresets[i].isCreateButton || newFilteredPresets[i].isCreateSpecificButton ? "__create__" : newFilteredPresets[i].name,
                presetData: newFilteredPresets[i]
            });
        }

        // Auto-select first item if searching
        if (searchText.length > 0 && newFilteredPresets.length > 0) {
            selectedIndex = 0;
            resultsList.currentIndex = 0;
        } else if (searchText.length === 0) {
            selectedIndex = -1;
            resultsList.currentIndex = -1;
        }
    }

    function enterCreateMode(presetName) {
        createMode = true;
        presetNameToCreate = presetName || "";
        selectedConfigFiles = availableConfigFiles.slice(); // Reset selection
        
        // Focus the input in the overlay
        // Use a timer to ensure visibility has propagated
        Qt.callLater(() => {
            createInput.forceActiveFocus();
            createInput.cursorPosition = createInput.text.length;
        });
    }

    function cancelCreateMode() {
        createMode = false;
        presetNameToCreate = "";
        searchInput.focusInput();
        updateFilteredPresets();
    }

    function confirmCreatePreset() {
        if (presetNameToCreate.trim() !== "" && selectedConfigFiles.length > 0) {
            PresetsService.savePreset(presetNameToCreate.trim(), selectedConfigFiles);
            cancelCreateMode();
        }
    }

    function loadPreset(presetName) {
        PresetsService.loadPreset(presetName);
        Visibilities.setActiveModule("");
    }

    Connections {
        target: PresetsService
        function onPresetsUpdated() {
            root.presets = PresetsService.presets;
            updateFilteredPresets();
        }
    }

    Component.onCompleted: {
        root.presets = PresetsService.presets;
        updateFilteredPresets();
    }

    implicitWidth: 400
    implicitHeight: 7 * 48 + 56

    Behavior on height {
        enabled: Config.animDuration > 0
        NumberAnimation {
            duration: Config.animDuration
            easing.type: Easing.OutQuart
        }
    }

    // Main Layout
    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // Search Input
        SearchInput {
            id: searchInput
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            
            text: root.searchText
            placeholderText: "Search or create preset..."
            
            onSearchTextChanged: text => {
                root.searchText = text;
            }

            onAccepted: {
                if (root.selectedIndex >= 0 && root.selectedIndex < presetsModel.count) {
                    let item = presetsModel.get(root.selectedIndex).presetData;
                    if (item.isCreateButton || item.isCreateSpecificButton) {
                        root.enterCreateMode(item.presetNameToCreate);
                    } else {
                        root.loadPreset(item.name);
                    }
                } else if (root.searchText.length > 0) {
                     // If nothing selected but text exists, assume creation if valid
                     root.enterCreateMode(root.searchText);
                }
            }
            
            onEscapePressed: {
                 Visibilities.setActiveModule("");
            }

            onDownPressed: {
                if (presetsModel.count > 0) {
                    if (root.selectedIndex < presetsModel.count - 1) {
                        root.selectedIndex++;
                    } else if (root.selectedIndex === -1) {
                        root.selectedIndex = 0;
                    }
                    resultsList.currentIndex = root.selectedIndex;
                }
            }

            onUpPressed: {
                if (root.selectedIndex > 0) {
                    root.selectedIndex--;
                    resultsList.currentIndex = root.selectedIndex;
                } else if (root.selectedIndex === 0 && root.searchText.length === 0) {
                    root.selectedIndex = -1;
                    resultsList.currentIndex = -1;
                }
            }
        }

        // List View
        ListView {
            id: resultsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            model: presetsModel
            currentIndex: root.selectedIndex

            // Scroll Animation
            Behavior on contentY {
                enabled: Config.animDuration > 0 && !resultsList.moving
                NumberAnimation {
                    duration: Config.animDuration / 2
                    easing.type: Easing.OutCubic
                }
            }

            onCurrentIndexChanged: {
                if (currentIndex !== root.selectedIndex && currentIndex !== -1) {
                    root.selectedIndex = currentIndex;
                }
            }

            highlight: Item {
                // Keyboard selection highlight (Standard)
                z: -1
                StyledRect {
                    anchors.fill: parent
                    variant: "primary" // Default highlight color
                    radius: Styling.radius(4)
                    visible: root.selectedIndex >= 0
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                }
            }
            highlightFollowsCurrentItem: true
            highlightMoveDuration: 150

            delegate: Item {
                width: resultsList.width
                height: 48
                
                required property var presetData
                required property int index
                
                property bool isCreate: presetData.isCreateButton || presetData.isCreateSpecificButton
                property bool isActive: !isCreate && presetData.name === root.activePreset
                property bool isSelected: root.selectedIndex === index

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        root.selectedIndex = index;
                        resultsList.currentIndex = index;
                    }
                    onClicked: {
                        if (isCreate) {
                            root.enterCreateMode(presetData.presetNameToCreate);
                        } else {
                            root.loadPreset(presetData.name);
                        }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 12

                    // Icon / Indicator
                    StyledRect {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        
                        // Logic for icon background color
                        variant: {
                            if (isSelected) return "overprimary"; // Selected item icon
                            if (isActive) return "primary";       // Active preset icon (if not selected)
                            if (isCreate) return "primary";       // Create button icon
                            return "common";
                        }
                        
                        radius: Styling.radius(-4)

                        Text {
                            anchors.centerIn: parent
                            text: isCreate ? Icons.plus : (isActive ? Icons.check : Icons.magicWand)
                            font.family: Icons.font
                            font.pixelSize: 16
                            color: parent.item
                        }
                    }

                    // Text Info
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        
                        Text {
                            text: presetData.name
                            color: isSelected ? Styling.styledRectItem("primary") : Colors.overSurface
                            font.family: Config.theme.font
                            font.pixelSize: Config.theme.fontSize
                            font.weight: isActive ? Font.Bold : Font.Normal
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            text: isCreate ? "Create a new preset" : `${presetData.configFiles.length} config files`
                            color: isSelected ? Styling.styledRectItem("primary") : Colors.outline
                            opacity: 0.7
                            font.family: Config.theme.font
                            font.pixelSize: Styling.fontSize(-2)
                            visible: true
                        }
                    }
                    
                    // Active Badge (Additional visual cue)
                    StyledRect {
                        visible: isActive && !isCreate
                        Layout.preferredHeight: 20
                        Layout.preferredWidth: 60
                        variant: isSelected ? "overprimary" : "primary"
                        radius: 10
                        
                        Text {
                            anchors.centerIn: parent
                            text: "ACTIVE"
                            font.family: Config.theme.font
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            color: parent.item
                        }
                    }
                }
            }
        }
    }

    // Create Mode Overlay
    Rectangle {
        id: createOverlay
        anchors.fill: parent
        color: Colors.background
        visible: createMode
        radius: 20 // Match popup radius
        
        // Prevent clicking through
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            Text {
                text: "Create New Preset"
                font.family: Config.theme.font
                font.pixelSize: Config.theme.fontSize + 4
                font.weight: Font.Bold
                color: Colors.overSurface
                Layout.alignment: Qt.AlignHCenter
            }

            // Name Input
            StyledRect {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                variant: "pane"
                radius: Styling.radius(4)

                TextInput {
                    id: createInput
                    anchors.fill: parent
                    anchors.margins: 8
                    verticalAlignment: TextInput.AlignVCenter
                    
                    text: root.presetNameToCreate
                    onTextChanged: {
                        if (root.createMode) root.presetNameToCreate = text;
                    }
                    
                    color: Colors.overSurface
                    font.family: Config.theme.font
                    font.pixelSize: Config.theme.fontSize
                    clip: true
                    
                    Keys.onEscapePressed: root.cancelCreateMode()
                    Keys.onEnterPressed: root.confirmCreatePreset()
                    Keys.onReturnPressed: root.confirmCreatePreset()
                    
                    Text {
                        anchors.fill: parent
                        verticalAlignment: TextInput.AlignVCenter
                        text: "Enter preset name..."
                        color: Colors.outline
                        font: parent.font
                        visible: parent.text === ""
                    }
                }
            }

            Text {
                text: "Select config files:"
                color: Colors.outline
                font.family: Config.theme.font
            }

            // File Selection Grid
            GridLayout {
                columns: 2
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                Repeater {
                    model: availableConfigFiles
                    delegate: Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        
                        property bool checked: root.selectedConfigFiles.includes(modelData)
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (parent.checked) {
                                    root.selectedConfigFiles = root.selectedConfigFiles.filter(f => f !== modelData);
                                } else {
                                    let list = root.selectedConfigFiles;
                                    list.push(modelData);
                                    root.selectedConfigFiles = list;
                                }
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            
                            // Checkbox
                            StyledRect {
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                                variant: parent.parent.checked ? "primary" : "pane"
                                radius: 4
                                border.width: parent.parent.checked ? 0 : 1
                                border.color: Colors.outline
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: Icons.check
                                    font.family: Icons.font
                                    visible: parent.parent.parent.checked
                                    color: Styling.styledRectItem("primary")
                                    font.pixelSize: 14
                                }
                            }
                            
                            Text {
                                text: modelData
                                color: parent.parent.checked ? Colors.overSurface : Colors.outline
                                font.family: Config.theme.font
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }

            // Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                // Cancel
                StyledRect {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    variant: "pane"
                    radius: 4
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: Colors.overSurface
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.cancelCreateMode()
                    }
                }

                // Create
                StyledRect {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    variant: "primary"
                    radius: 4
                    opacity: (root.presetNameToCreate.trim() !== "" && root.selectedConfigFiles.length > 0) ? 1 : 0.5
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Create"
                        color: Styling.styledRectItem("primary")
                        font.weight: Font.Bold
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        enabled: parent.opacity === 1
                        onClicked: root.confirmCreatePreset()
                    }
                }
            }
        }
    }
}
