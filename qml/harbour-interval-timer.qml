import QtQuick 2.6
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow
{
    id: appWindow

    initialPage: Component {
        SetupPage { }
    }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: Orientation.All
}