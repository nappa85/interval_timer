import QtQuick 2.6
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import Nemo.Notifications 1.0
import "../components"

Page
{
    id: page
    allowedOrientations: Orientation.All

    ConfigurationGroup {
        id: settings
        path: "/apps/harbour-interval-timer/settings"
    }

    Notification {
        id: notification
        isTransient: true
    }

    property int sets: 8
    property int setDuration: 60
    property int restDuration: 30

    property int startCountdownMs: 5000

    function fmt(seconds) {
        var m = Math.floor(seconds / 60)
        var s = seconds % 60
        return m + ":" + (s < 10 ? "0" : "") + s
    }

    function totalSeconds() {
        return sets * setDuration + Math.max(0, sets - 1) * restDuration + startCountdownMs / 1000
    }

    function loadPresetList() {
        var raw = settings.value("presets", "[]")
        var list = []
        try { list = JSON.parse(raw) } catch (e) {}
        return list
    }

    function savePresetList(list) {
        settings.setValue("presets", JSON.stringify(list))
    }

    function presetCount() {
        return loadPresetList().length
    }

    function savePreset(name) {
        var list = loadPresetList()
        list.push({ name: name, sets: sets, setDuration: setDuration, restDuration: restDuration })
        savePresetList(list)
        refreshPresetList()
    }

    function loadPreset(index) {
        var list = loadPresetList()
        if (index < 0 || index >= list.length) return
        sets = list[index].sets
        setDuration = list[index].setDuration
        restDuration = list[index].restDuration
    }

    function deletePreset(index) {
        var list = loadPresetList()
        if (index < 0 || index >= list.length) return
        list.splice(index, 1)
        savePresetList(list)
        refreshPresetList()
    }

    function refreshPresetList() {
        presetMenu.clear()
        var list = loadPresetList()
        for (var i = 0; i < list.length; ++i) {
            var p = list[i]
            presetMenu.append({ text: p.name + "  -  " + p.sets + "x " + p.setDuration + "/" + p.restDuration + "s" })
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Active)
            refreshPresetList()
    }

    SilicaFlickable
    {
        id: flick
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        PullDownMenu
        {
            MenuItem {
                text: "Save as preset"
                onClicked: pageStack.push(savePresetDialog)
            }
            MenuItem {
                text: "Load preset"
                enabled: page.presetCount() > 0
                onClicked: pageStack.push(loadPresetDialog)
            }
            MenuItem {
                text: "Delete preset"
                enabled: page.presetCount() > 0
                onClicked: pageStack.push(deletePresetDialog)
            }
        }

        Column
        {
            id: column
            width: parent.width

            PageHeader { title: "Interval Timer" }

            SectionHeader { text: "Workout" }

            SteppedSlider {
                id: setsSlider
                width: parent.width
                minimumValue: 1
                maximumValue: 30
                stepSize: 1
                value: page.sets
                label: "Sets"
                valueText: value
                onValueChanged: page.sets = value
            }

            SteppedSlider {
                id: setSlider
                width: parent.width
                minimumValue: 1
                maximumValue: 600
                stepSize: 1
                value: page.setDuration
                label: "Set duration (s)"
                valueText: page.fmt(value)
                onValueChanged: page.setDuration = value
            }

            SteppedSlider {
                id: restSlider
                width: parent.width
                minimumValue: 0
                maximumValue: 600
                stepSize: 1
                value: page.restDuration
                label: "Rest duration (s)"
                valueText: value === 0 ? "none" : page.fmt(value)
                onValueChanged: page.restDuration = value
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                height: Theme.itemSizeExtraSmall
                verticalAlignment: Text.AlignVCenter
                color: Theme.secondaryHighlightColor
                text: "Total: ~" + page.fmt(page.totalSeconds())
            }

            Button {
                id: startButton
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Start"
                onClicked: pageStack.push(Qt.resolvedUrl("TimerPage.qml"), {
                                             sets: page.sets,
                                             setDuration: page.setDuration,
                                             restDuration: page.restDuration
                                         })
            }
        }
    }

    Component {
        id: savePresetDialog
        Dialog {
            id: saveDlg
            property var textField: null

            canAccept: textField !== null && textField.text.length > 0

            onAccepted: {
                page.savePreset(textField.text.trim())
                notification.summary = "Preset saved"
                notification.publish()
            }

            Column {
                id: saveCol
                width: parent.width

                DialogHeader { title: "Save preset" }

                TextField {
                    id: nameField
                    width: parent.width
                    placeholderText: "Preset name"
                    label: "Preset name"
                    EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                    EnterKey.onClicked: saveDlg.accept()
                    onTextChanged: saveDlg.textField = nameField
                }
            }
            onStatusChanged: {
                if (status === PageStatus.Active)
                    nameField.focus = true
            }
        }
    }

    ListModel { id: presetMenu }

    Component {
        id: loadPresetDialog
        Dialog {
            id: loadDlg
            canAccept: loadCombo.currentIndex >= 0

            onAccepted: {
                page.loadPreset(loadCombo.currentIndex)
                notification.summary = "Preset loaded"
                notification.publish()
            }

            Column {
                id: loadCol
                width: parent.width

                DialogHeader { title: "Load preset" }

                ComboBox {
                    id: loadCombo
                    width: parent.width
                    label: "Preset"
                    menu: ContextMenu {
                        Repeater {
                            model: presetMenu
                            MenuItem { text: model.text }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: deletePresetDialog
        Dialog {
            id: delDlg
            canAccept: delCombo.currentIndex >= 0

            onAccepted: {
                page.deletePreset(delCombo.currentIndex)
                notification.summary = "Preset deleted"
                notification.publish()
            }

            Column {
                id: delCol
                width: parent.width

                DialogHeader { title: "Delete preset" }

                ComboBox {
                    id: delCombo
                    width: parent.width
                    label: "Preset"
                    menu: ContextMenu {
                        Repeater {
                            model: presetMenu
                            MenuItem { text: model.text }
                        }
                    }
                }
            }
        }
    }
}