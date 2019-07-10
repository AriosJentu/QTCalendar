#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>

int main(int argc, char *argv[]) {

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    const QUrl asset(QStringLiteral("assets:/assets/localbase.db"));

    engine.setOfflineStoragePath(QString("./"));

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,

        [url](QObject *obj, const QUrl &objUrl) {

            if (!obj && url == objUrl) {
                QCoreApplication::exit(-1);
            }
        },
        Qt::QueuedConnection
    );

    engine.load(url);

    app.applicationDirPath();

    return app.exec();
}
