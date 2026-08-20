TARGET = harbour-interval-timer

CONFIG += sailfishapp

VERSION = 0.1.1
DEFINES += APP_VERSION=\\\"$$VERSION\\\"

SOURCES += \
    src/harbour-interval-timer.cpp

DISTFILES += \
    rpm/harbour-interval-timer.spec \
    harbour-interval-timer.desktop \
    qml/harbour-interval-timer.qml \
    qml/cover/CoverPage.qml \
    qml/pages/SetupPage.qml \
    qml/pages/TimerPage.qml \
    qml/components/SteppedSlider.qml \
    qml/sounds/beep_short.wav \
    qml/sounds/beep_long.wav \
    qml/sounds/beep_end.wav

icon86.files = icons/86x86/harbour-interval-timer.png
icon86.path = /usr/share/icons/hicolor/86x86/apps
icon108.files = icons/108x108/harbour-interval-timer.png
icon108.path = /usr/share/icons/hicolor/108x108/apps
icon128.files = icons/128x128/harbour-interval-timer.png
icon128.path = /usr/share/icons/hicolor/128x128/apps
icon172.files = icons/172x172/harbour-interval-timer.png
icon172.path = /usr/share/icons/hicolor/172x172/apps

INSTALLS += icon86 icon108 icon128 icon172
