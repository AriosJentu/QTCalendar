#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QUrlQuery>
#include <QJsonDocument>

//#include "event.h"
//#include "eventmodel.h"
//#include "sevent.h"
//#include "seventmodel.h"

/*void getRequestTest() {
    //Test GET request

    QNetworkAccessManager* manager = new QNetworkAccessManager();
    QNetworkRequest request;

    QUrlQuery urlquery;
    urlquery.addQueryItem("count", "100");

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
        //qDebug() << arr;

        QJsonDocument doc = QJsonDocument::fromJson(arr);
        Server::EventResponse resp(doc.object());
        qDebug() << resp.getCount() << resp.getStatus() << resp.getData().length();
        foreach (Server::Event* evt, resp.getData()) {
            qDebug() << evt->getName() << evt->getCreationTime() << evt->getUpdateTime();
        }

    });

    manager->get(request);

    qint64 time = 1562126697917;
    QJsonValue val = "1562126697917";
    QDateTime dat = QDateTime::fromMSecsSinceEpoch(time);
    qDebug() << dat << QDateTime::fromMSecsSinceEpoch(val.toVariant().toLongLong()) << QDateTime::fromTime_t(static_cast<uint>(0));
    qint64 ntime = dat.toMSecsSinceEpoch();
    qDebug() << time << ntime;

    QDate date = QDate::currentDate();
    QDateTime start(date);
    QDateTime end = QDateTime(date.addDays(1)).addSecs(-1);

    qDebug() << start << end;

    //Test GET request finished
}*/

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    //qmlRegisterType<Server::EventModel>("org.jentucalendar.calendar", 1, 0, "EventModel");

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    const QUrl asset(QStringLiteral("assets:/assets/localbase.db"));

    engine.setOfflineStoragePath(QString("./"));

    //Server::EventModel();

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

    /*QNetworkAccessManager* manager = new QNetworkAccessManager();
    QString start = "1561665600000";
    QString end = "1581674400000";

    QUrlQuery query;
    query.addQueryItem("from", start);
    query.addQueryItem("to", end);

    QUrl location("http://planner.skillmasters.ga/api/v1/events/instances");
    location.setQuery(query);

    QNetworkRequest request(location);
    request.setRawHeader("X-Firebase-Auth", "serega_mem");

    QObject::connect(manager, &QNetworkAccessManager::finished, [=](QNetworkReply* reply) {
        if (reply->error()) {
            qDebug() << reply->errorString();
            return;
        }
        QByteArray jsonreply = reply->readAll();

        QJsonDocument document = QJsonDocument::fromJson(jsonreply);
        Server::EventInstanceResponse response(document.object());

        QList<QObject*> data;
        foreach (Server::EventInstance* obj, response.getData()) {
            QObject* nobj = obj;
            data.append(nobj);
            //qDebug() << "Testing data:" << obj->getEventID() << obj->getStartTime();
        }
        //qDebug() << "";

        if (data.length() == 0) {
            return;
        }


    });

    manager->get(request);

    start = "1561665600000";
    end = "1581674400000";

    QUrlQuery nquery;
    nquery.addQueryItem("from", start);
    nquery.addQueryItem("to", end);

    location = QUrl("http://planner.skillmasters.ga/api/v1/events/instances");
    location.setQuery(query);

    request.setUrl(location);
    manager->get(request);*/

    return app.exec();
}
