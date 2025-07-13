import QtQuick

Text {
    id: timeDisplay

    property string currentTime: ""

    text: currentTime
    color: "#ffffff"
    font.pixelSize: 12
    font.family: "Iosevka Nerd Font"

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var now = new Date();
            timeDisplay.currentTime = Qt.formatDateTime(now, "hh:mm:ss");
        }
    }
}