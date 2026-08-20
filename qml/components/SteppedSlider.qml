import QtQuick 2.6
import Sailfish.Silica 1.0

Item
{
    id: root
    width: parent.width
    height: slider.height

    property alias label: slider.label
    property alias minimumValue: slider.minimumValue
    property alias maximumValue: slider.maximumValue
    property alias stepSize: slider.stepSize
    property alias value: slider.value
    property alias valueText: slider.valueText

    readonly property real trackCenter: {
        if (slider.valueText !== "" || slider.label !== "")
            return root.height - (Theme.fontSizeSmall + Theme.paddingSmall + 1) - Theme.itemSizeExtraSmall / 4
        return root.height / 2
    }

    function step(dir) {
        var delta = slider.stepSize * (dir > 0 ? 1 : -1)
        slider.value = Math.min(slider.maximumValue, Math.max(slider.minimumValue, slider.value + delta))
    }

    IconButton {
        id: minusBtn
        anchors.left: parent.left
        anchors.verticalCenter: parent.top
        anchors.verticalCenterOffset: root.trackCenter
        icon.source: "image://theme/icon-m-minus"
        enabled: slider.value > slider.minimumValue
        onPressed: root.step(-1)
        onPressAndHold: repeatMinus.start()
        onReleased: repeatMinus.stop()
        onCanceled: repeatMinus.stop()
        onExited: repeatMinus.stop()
        onEnabledChanged: if (!enabled) repeatMinus.stop()

        Timer {
            id: repeatMinus
            interval: 180
            repeat: true
            onTriggered: root.step(-1)
        }
    }

    Slider {
        id: slider
        anchors.left: minusBtn.right
        anchors.right: plusBtn.left
        leftMargin: Theme.paddingLarge * 3
        rightMargin: Theme.paddingLarge * 3
    }

    IconButton {
        id: plusBtn
        anchors.right: parent.right
        anchors.verticalCenter: parent.top
        anchors.verticalCenterOffset: root.trackCenter
        icon.source: "image://theme/icon-m-plus"
        enabled: slider.value < slider.maximumValue
        onPressed: root.step(1)
        onPressAndHold: repeatPlus.start()
        onReleased: repeatPlus.stop()
        onCanceled: repeatPlus.stop()
        onExited: repeatPlus.stop()
        onEnabledChanged: if (!enabled) repeatPlus.stop()

        Timer {
            id: repeatPlus
            interval: 180
            repeat: true
            onTriggered: root.step(1)
        }
    }
}