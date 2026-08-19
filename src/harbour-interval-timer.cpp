#include <sailfishapp.h>
#include <QGuiApplication>
#include <QQuickView>
#include <QtQml>

int main(int argc, char *argv[])
{
    QGuiApplication *app = SailfishApp::application(argc, argv);
    QQuickView *view = SailfishApp::createView();

    view->setSource(SailfishApp::pathTo(QStringLiteral("qml/harbour-interval-timer.qml")));
    view->show();

    return app->exec();
}