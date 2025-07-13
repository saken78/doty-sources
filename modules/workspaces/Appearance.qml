import QtQuick
pragma Singleton

QtObject {
    readonly property QtObject rounding: QtObject {
        readonly property real full: 12
        readonly property real medium: 8
        readonly property real small: 4
    }
    
    readonly property QtObject font: QtObject {
        readonly property QtObject pixelSize: QtObject {
            readonly property real small: 10
            readonly property real medium: 12
            readonly property real large: 14
        }
    }
    
    readonly property QtObject colors: QtObject {
        readonly property color colPrimary: "#db4740"
        readonly property color colOnLayer1Inactive: "#888888"
    }
    
    readonly property QtObject m3colors: QtObject {
        readonly property color m3secondaryContainer: "#333333"
        readonly property color m3onPrimary: "#ffffff"
        readonly property color m3onSecondaryContainer: "#cccccc"
    }
    
    readonly property QtObject animation: QtObject {
        readonly property QtObject elementMove: QtObject {
            readonly property Component numberAnimation: Component {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }
        }
        readonly property QtObject elementMoveFast: QtObject {
            readonly property Component numberAnimation: Component {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutQuad
                }
            }
        }
    }
}