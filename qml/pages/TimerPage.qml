import QtQuick 2.6
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import Nemo.KeepAlive 1.2

Page
{
    id: page
    allowedOrientations: Orientation.All

    DisplayBlanking {
        id: screenKeepAlive
        preventBlanking: page.running
    }

    property int sets: 8
    property int setDuration: 60
    property int restDuration: 30

    property int startCountdownMs: 5000
    property double deadline: 0
    property double currentMs: 0
    property int lastBeepSecond: -1
    property string phase: "start"          // start | set | rest | done
    property int currentSet: 0
    property bool running: false

    function fmt(seconds) {
        var m = Math.floor(seconds / 60)
        var s = seconds % 60
        return m + ":" + (s < 10 ? "0" : "") + s
    }

    function phaseTitle() {
        if (phase === "start")
            return "Get ready"
        if (phase === "set")
            return "Set " + currentSet + " of " + sets
        if (phase === "rest")
            return "Rest"
        return "Workout complete!"
    }

    function remainingSeconds() {
        return Math.max(0, Math.ceil(currentMs / 1000))
    }

    function currentPhaseTotal() {
        if (phase === "start") return startCountdownMs
        if (phase === "set") return setDuration * 1000
        if (phase === "rest") return restDuration * 1000
        return 1
    }

    function startWorkout() {
        phase = "start"
        currentSet = 0
        lastBeepSecond = -1
        deadline = Date.now() + startCountdownMs
        currentMs = startCountdownMs
        running = true
        tickTimer.start()
        tickTimer.interval = 200
    }

    function advance() {
        if (phase === "start") {
            currentSet = 1
            phase = "set"
            deadline = Date.now() + setDuration * 1000
            beepLong.play()
        } else if (phase === "set") {
            if (currentSet >= sets) {
                running = false
                tickTimer.stop()
                phase = "done"
                currentMs = 0
                beepEnd.play()
                return
            }
            if (restDuration > 0) {
                phase = "rest"
                deadline = Date.now() + restDuration * 1000
            } else {
                currentSet++
                phase = "set"
                deadline = Date.now() + setDuration * 1000
            }
            beepLong.play()
        } else if (phase === "rest") {
            currentSet++
            phase = "set"
            deadline = Date.now() + setDuration * 1000
            beepLong.play()
        }
        lastBeepSecond = -1
        tick()
    }

    function tick() {
        currentMs = deadline - Date.now()
        if (currentMs <= 0) {
            advance()
            return
        }
        var s = Math.ceil(currentMs / 1000)
        if (s !== lastBeepSecond) {
            lastBeepSecond = s
            if (phase === "start" || (s >= 1 && s <= 3))
                beepShort.play()
        }
    }

    Timer {
        id: tickTimer
        repeat: true
        onTriggered: page.tick()
    }

    SoundEffect {
        id: beepShort
        source: Qt.resolvedUrl("../sounds/beep_short.wav")
        volume: 1.0
    }
    SoundEffect {
        id: beepLong
        source: Qt.resolvedUrl("../sounds/beep_long.wav")
        volume: 1.0
    }
    SoundEffect {
        id: beepEnd
        source: Qt.resolvedUrl("../sounds/beep_end.wav")
        volume: 1.0
    }

    onStatusChanged: {
        if (status === PageStatus.Active && !running)
            startWorkout()
    }

    SilicaFlickable
    {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        Column
        {
            id: column
            width: parent.width

            PageHeader { title: "Workout" }

            Label {
                id: phaseLabel
                anchors.horizontalCenter: parent.horizontalCenter
                text: page.phaseTitle()
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
            }

            Label {
                id: timeLabel
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: page.phase === "done" ? "✓" : page.fmt(page.remainingSeconds())
                color: page.phase === "rest" ? "#7cb342" : (page.phase === "set" ? Theme.primaryColor : Theme.secondaryHighlightColor)
                font.pixelSize: Theme.fontSizeHuge * 1.6
                font.bold: true
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: {
                    if (page.phase === "done")
                        return "All " + page.sets + " sets completed"
                    if (page.phase === "set" && page.restDuration > 0)
                        return "then " + page.fmt(page.restDuration) + " rest"
                    if (page.phase === "rest")
                        return "next: set " + (page.currentSet + 1) + " of " + page.sets
                    return ""
                }
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                visible: text.length > 0
            }

            ProgressBar {
                id: progress
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 2 * Theme.horizontalPageMargin
                value: page.running ? Math.max(0, (page.currentPhaseTotal() - page.currentMs) / page.currentPhaseTotal())
                                    : (page.phase === "done" ? 1 : 0)
            }

            Button {
                id: stopButton
                anchors.horizontalCenter: parent.horizontalCenter
                text: page.phase === "done" ? "Back" : "Stop"
                onClicked: pageStack.pop()
            }
        }
    }
}