#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QUrlQuery>
#include <QJsonDocument>

#include "event.h"
#include "eventmodel.h"
#include "sevent.h"

void getRequestTest() {
    //Test GET request

    QNetworkAccessManager* manager = new QNetworkAccessManager();
    QNetworkRequest request;

    QUrlQuery urlquery;
    urlquery.addQueryItem("count", "2");

    QUrl dir("http://planner.skillmasters.ga/api/v1/events");
    dir.setQuery(urlquery);

    request.setUrl(dir);
    request.setRawHeader("X-Firebase-Auth", "serega_mem");

    QObject::connect(manager, &QNetworkAccessManager::finished, [=](QNetworkReply* reply) {
        if (reply->error()) {
            qDebug() << reply->errorString();
            return;
        }
        QByteArray arr = reply->readAll();
        qDebug() << arr;

        QJsonDocument doc = QJsonDocument::fromJson(arr);
        Server::EventResponse resp(doc.object());
        qDebug() << resp.getCount() << resp.getStatus();

    });

    manager->get(request);

    //Test GET request finished
}

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

    /*
    Event today;
    today.setName("Welcome to the future");
    today.setInfo("Were going to use this bullshit at the end of the starts");
    today.setStartDate(QDateTime(QDate(2019, 7, 5), QTime(12, 16, 25)));
    today.setEndDate(QDateTime(QDate(2019, 7, 8), QTime(12, 19, 26)));
    today.setRepeating(QDateTime(QDate(0, 0, 0), QTime(0, 0, 0)));

    EventModel model;
    model.addEvent(today);
    */

    app.applicationDirPath();

    getRequestTest();

    return app.exec();
}
