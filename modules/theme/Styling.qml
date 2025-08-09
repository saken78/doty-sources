pragma Singleton
import QtQuick
import qs.config

QtObject {
    readonly property string defaultFont: Config.defaultFont
}
