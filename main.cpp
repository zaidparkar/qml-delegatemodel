#include "ModelClass.h"
#include <QGuiApplication>
#include <QQmlApplicationEngine>

void registerTypes() {
    qmlRegisterType<ModelClass>("ModelClass",1,0,"ContactClass");
}


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    registerTypes();

    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/contactsPicker/Main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
