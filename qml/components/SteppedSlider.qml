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

    Item {
        id: minusBtn
        anchors.left: parent.left
        anchors.verticalCenter: parent.top
        anchors.verticalCenterOffset: root.trackCenter
        width: Theme.itemSizeMedium
        height: Theme.itemSizeMedium
        enabled: slider.value > slider.minimumValue

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: minusBtn.enabled ? Theme.rgba(Theme.highlightColor, 0.18) : "transparent"
            border.width: minusBtn.enabled ? 2 : 0
            border.color: Theme.rgba(Theme.highlightColor, 0.6)
        }
        Label {
            anchors.centerIn: parent
            text: "−"
            font.pixelSize: Theme.fontSizeExtraLarge
            color: minusBtn.enabled ? Theme.primaryColor : Theme.secondaryColor
        }
        MouseArea {
            anchors.fill: parent
            onPressed: root.step(-1)
            onPressAndHold: repeatMinus.start()
            onReleased: repeatMinus.stop()
            onCanceled: repeatMinus.stop()
            onExited: repeatMinus.stop()
        }
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
        leftMargin: Theme.paddingMedium
        rightMargin: Theme.paddingMedium
    }

    Item {
        id: plusBtn
        anchors.right: parent.right
        anchors.verticalCenter: parent.top
        anchors.verticalCenterOffset: root.trackCenter
        width: Theme.itemSizeMedium
        height: Theme.itemSizeMedium
        enabled: slider.value < slider.maximumValue

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: plusBtn.enabled ? Theme.rgba(Theme.highlightColor, 0.18) : "transparent"
            border.width: plusBtn.enabled ? 2 : 0
            border.color: Theme.rgba(Theme.highlightColor, 0.6)
        }
        Label {
            anchors.centerIn: parent
            text: "+"
            font.pixelSize: Theme.fontSizeExtraLarge
            color: plusBtn.enabled ? Theme.primaryColor : Theme.secondaryColor
        }
        MouseArea {
            anchors.fill: parent
            onPressed: root.step(1)
            onPressAndHold: repeatPlus.start()
            onReleased: repeatPlus.stop()
            onCanceled: repeatPlus.stop()
            onExited: repeatPlus.stop()
        }
        onEnabledChanged: if (!enabled) repeatPlus.stop()
        Timer {
            id: repeatPlus
            interval: 180
            repeat: true
            onTriggered: root.step(1)
        }
    }
}