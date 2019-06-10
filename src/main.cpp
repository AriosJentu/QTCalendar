#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "event.h"
#include "eventmodel.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    qmlRegisterType<EventModel>("org.jentucalendar.calendar", 1, 0, "EventModel");
//    qmlRegisterType<Event>("org.jentucalendar.calendar", 1, 0, "Event");

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    const QUrl asset(QStringLiteral("assets:/assets/localbase.db"));

    engine.setOfflineStoragePath(QString("./"));

    EventModel::createConnection();
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

    /*Event today;
    today.setName("Welcome to the future");
    today.setInfo("Were going to use this bullshit at the end of the starts");
    today.setStartDate(QDateTime(QDate(2019, 6, 5), QTime(12, 16, 25)));
    today.setEndDate(QDateTime(QDate(2019, 6, 5), QTime(12, 19, 26)));

    EventModel model;
    model.addEvent(today);*/

    app.applicationDirPath();

    return app.exec();
}
