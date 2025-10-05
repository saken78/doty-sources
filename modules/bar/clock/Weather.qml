import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.config
import qs.modules.theme
import qs.modules.components

BgRect {
    id: weatherContainer
    visible: weatherVisible

    // Day + weather raw values
    property string currentDayAbbrev: ""
    property string weatherSymbol: ""            // weather icon / emoji
    property string weatherTemp: ""              // temperature text

    property bool weatherVisible: false
    required property var bar
    property bool vertical: bar.orientation === "vertical"

    // Weather retry / backoff
    property int weatherRetryCount: 0
    property int weatherMaxRetries: 5
    
    property string cachedLat: ""
    property string cachedLon: ""

    Layout.preferredWidth: vertical ? 36 : rowLayout.implicitWidth + 20
    implicitHeight: vertical ? columnLayout.implicitHeight + 20 : 36
    Layout.preferredHeight: implicitHeight

    RowLayout { // horizontal layout
        id: rowLayout
        visible: !vertical
        anchors.centerIn: parent
        spacing: 4

        Text {
            id: symbolDisplay
            text: weatherContainer.weatherSymbol
            color: Colors.overBackground
            font.pixelSize: 16
            font.family: Config.theme.font
            font.bold: true
        }

        Separator {
            id: separator
        }

        Text {
            id: tempDisplay
            text: weatherContainer.weatherTemp
            color: Colors.overBackground
            font.pixelSize: Config.theme.fontSize
            font.family: Config.theme.font
            font.bold: true
        }
    }

    ColumnLayout { // vertical layout
        id: columnLayout
        visible: vertical
        anchors.centerIn: parent
        spacing: 4
        Layout.alignment: Qt.AlignHCenter

        Text {
            id: symbolDisplayV
            text: weatherContainer.weatherSymbol
            color: Colors.overBackground
            font.pixelSize: 16
            font.family: Config.theme.font
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.NoWrap
            Layout.alignment: Qt.AlignHCenter
        }

        Separator {
            id: separatorV
            vert: true
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            id: tempDisplayV
            text: weatherContainer.vertical && weatherContainer.weatherTemp.length > 0 ? weatherContainer.weatherTemp.slice(0, -1) : weatherContainer.weatherTemp
            color: Colors.overBackground
            font.pixelSize: Config.theme.fontSize
            font.family: Config.theme.font
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.NoWrap
            Layout.alignment: Qt.AlignHCenter
        }
    }

    function getWeatherCodeEmoji(code) {
        if (code === 0) return "☀️";
        if (code < 3) return "🌤️";
        if (code < 50) return "☁️";
        if (code < 70) return "🌧️";
        if (code < 90) return "⛈️";
        return "❄️";
    }

    function fetchWeatherWithCoords(lat, lon) {
        var url = "https://api.open-meteo.com/v1/forecast?latitude=" + lat + "&longitude=" + lon + "&current_weather=true";
        weatherProcess.command = ["curl", "-s", url];
        weatherProcess.running = true;
    }

    function urlEncode(str) {
        return str.replace(/%/g, "%25")
                  .replace(/ /g, "%20")
                  .replace(/!/g, "%21")
                  .replace(/"/g, "%22")
                  .replace(/#/g, "%23")
                  .replace(/\$/g, "%24")
                  .replace(/&/g, "%26")
                  .replace(/'/g, "%27")
                  .replace(/\(/g, "%28")
                  .replace(/\)/g, "%29")
                  .replace(/\*/g, "%2A")
                  .replace(/\+/g, "%2B")
                  .replace(/,/g, "%2C")
                  .replace(/\//g, "%2F")
                  .replace(/:/g, "%3A")
                  .replace(/;/g, "%3B")
                  .replace(/=/g, "%3D")
                  .replace(/\?/g, "%3F")
                  .replace(/@/g, "%40")
                  .replace(/\[/g, "%5B")
                  .replace(/]/g, "%5D");
    }

    function updateWeather() {
        var location = Config.weather.location.trim();
        if (location.length === 0) {
            weatherContainer.weatherVisible = false;
            return;
        }

        var coords = location.split(",");
        var isCoordinates = coords.length === 2 && 
                           !isNaN(parseFloat(coords[0].trim())) && 
                           !isNaN(parseFloat(coords[1].trim()));

        if (isCoordinates) {
            cachedLat = coords[0].trim();
            cachedLon = coords[1].trim();
            console.log("Weather: using coordinates", cachedLat + "," + cachedLon);
            fetchWeatherWithCoords(cachedLat, cachedLon);
        } else {
            var encodedCity = urlEncode(location);
            console.log("Weather: geocoding location '" + location + "' -> '" + encodedCity + "'");
            var geocodeUrl = "https://geocoding-api.open-meteo.com/v1/search?name=" + encodedCity;
            geocodingProcess.command = ["curl", "-s", geocodeUrl];
            geocodingProcess.running = true;
        }
    }

    function scheduleNextDayUpdate() {
        var now = new Date();
        var next = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1, 0, 0, 1); // 1 second after midnight
        var ms = next - now;
        dayUpdateTimer.interval = ms;
        dayUpdateTimer.start();
    }

    function updateDay() {
        var now = new Date();
        var day = Qt.formatDateTime(now, Qt.locale(), "ddd");
        weatherContainer.currentDayAbbrev = day.slice(0, 3).charAt(0).toUpperCase() + day.slice(1, 3);
        scheduleNextDayUpdate();
    }

    Process {
        id: geocodingProcess
        running: false
        command: []

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var raw = text.trim();
                if (raw.length > 0) {
                    try {
                        var data = JSON.parse(raw);
                        if (data.results && data.results.length > 0) {
                            var result = data.results[0];
                            cachedLat = result.latitude.toString();
                            cachedLon = result.longitude.toString();
                            fetchWeatherWithCoords(cachedLat, cachedLon);
                        } else {
                            console.log("Geocoding: no results for location");
                            weatherContainer.weatherVisible = false;
                        }
                    } catch (e) {
                        console.log("Geocoding JSON parse error:", e);
                        weatherContainer.weatherVisible = false;
                    }
                }
            }
        }

        onExited: function (code) {
            if (code !== 0) {
                console.log("Geocoding fetch failed");
                weatherContainer.weatherVisible = false;
            }
        }
    }

    Process {
        id: weatherProcess
        running: false
        command: []

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var raw = text.trim();
                if (raw.length > 0) {
                    try {
                        var data = JSON.parse(raw);
                        if (data.current_weather) {
                            var weather = data.current_weather;
                            var code = parseInt(weather.weathercode);
                            var temp = parseFloat(weather.temperature);
                            
                            if (Config.weather.unit === "F") {
                                temp = (temp * 9/5) + 32;
                            }
                            
                            weatherContainer.weatherSymbol = getWeatherCodeEmoji(code);
                            weatherContainer.weatherTemp = Math.round(temp) + "°" + Config.weather.unit;
                            weatherContainer.weatherVisible = true;
                            weatherContainer.weatherRetryCount = 0;
                        } else {
                            weatherContainer.weatherVisible = false;
                            if (weatherContainer.weatherRetryCount < weatherContainer.weatherMaxRetries) {
                                weatherContainer.weatherRetryCount++;
                                weatherRetryTimer.interval = Math.min(600000, 5000 * Math.pow(2, weatherContainer.weatherRetryCount - 1));
                                weatherRetryTimer.start();
                            }
                        }
                    } catch (e) {
                        console.log("Weather JSON parse error:", e);
                        weatherContainer.weatherVisible = false;
                        if (weatherContainer.weatherRetryCount < weatherContainer.weatherMaxRetries) {
                            weatherContainer.weatherRetryCount++;
                            weatherRetryTimer.interval = Math.min(600000, 5000 * Math.pow(2, weatherContainer.weatherRetryCount - 1));
                            weatherRetryTimer.start();
                        }
                    }
                }
            }
        }

        onExited: function (code) {
            if (code !== 0) {
                console.log("Weather fetch failed");
                weatherContainer.weatherVisible = false;
                if (weatherContainer.weatherRetryCount < weatherContainer.weatherMaxRetries) {
                    weatherContainer.weatherRetryCount++;
                    weatherRetryTimer.interval = Math.min(600000, 5000 * Math.pow(2, weatherContainer.weatherRetryCount - 1));
                    weatherRetryTimer.start();
                }
            }
        }
    }

    Timer { // retry weather with exponential backoff on failure
        id: weatherRetryTimer
        repeat: false
        running: false
        onTriggered: updateWeather()
    }

    Timer {
        // periodic weather refresh (every 10 minutes)
        interval: 600000
        running: true
        repeat: true
        onTriggered: updateWeather()
    }

    Timer { // schedule-based day update (fires at next midnight + 1s)
        id: dayUpdateTimer
        repeat: false
        running: false
        onTriggered: updateDay()
    }

    Connections {
        target: Config.weather
        function onLocationChanged() {
            updateWeather();
        }
        function onUnitChanged() {
            updateWeather();
        }
    }

    Component.onCompleted: {
        updateWeather();
        updateDay();
    }
}
