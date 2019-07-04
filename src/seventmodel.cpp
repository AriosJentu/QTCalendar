#include "seventmodel.h"
#include "consts.h"

using namespace Server;

void EventView::replyEventFunction(QNetworkReply* reply) {

    qDebug() << "I'm here";
    if (reply->error()) {
        qDebug() << reply->errorString();
        return;
    }
    QByteArray jsonreply = reply->readAll();

    QJsonDocument document = QJsonDocument::fromJson(jsonreply);
    Server::EventResponse response(document.object());

    if (response.getSuccess() == true) {
        Server::Event* evt = response.getData()[0];
        name = evt->getName();
        details = evt->getDetails();
        owner_id = evt->getOwnerID();
        location = evt->getLocation();
    }
}

EventView::EventView(EventInstance* instance) {

    id = instance->getEventID();
    pattern_id = instance->getPatternID();
    start_time = instance->getStartTime();
    end_time = instance->getEndTime();

    QUrl urllocation(Consts::srv_events+"/"+QString::number(id));

    QNetworkRequest request(urllocation);
    request.setRawHeader(Consts::AuthName, Consts::AuthToken);

    QNetworkAccessManager* nmanager = new QNetworkAccessManager();

    QObject::connect(nmanager, SIGNAL(finished(QNetworkReply*)), this, SLOT(replyEventFunction(QNetworkReply*)), Qt::UniqueConnection);
    nmanager->get(request);

}

//Event Model

EventModel::EventModel() {};

void EventModel::replyFunction(QNetworkReply* reply) {

    qDebug() << "Calling connector for function eventsForDate";

    if (reply->error()) {
        qDebug() << reply->errorString();
        return;
    }
    QByteArray jsonreply = reply->readAll();

    if (jsonreply.length() == 0) {
        return;
    }

    QJsonDocument document = QJsonDocument::fromJson(jsonreply);
    Server::EventInstanceResponse response(document.object());

    QList<QObject*> data;
    foreach (Server::EventInstance* obj, response.getData()) {
        if (obj->getEventID() != 0) {
            QObject* val = new EventView(obj);
            data.append(val);
        }
    }

    emit eventsAvailable(data);

    return;
}

void EventModel::eventsForDate(const QDate &date) {

    qint64 start = fromDateToTimestamp(QDateTime(date));
    qint64 end = fromDateToTimestamp(QDateTime(date.addDays(1)).addSecs(-1));
    //qDebug() << "Times: " << start << end;

    QUrlQuery query;
    query.addQueryItem("from", QString::number(start));
    query.addQueryItem("to", QString::number(end));

    QUrl location(Consts::srv_instances);
    location.setQuery(query);

    QNetworkRequest request(location);
    request.setRawHeader(Consts::AuthName, Consts::AuthToken);
    qDebug() << "Calling function eventsForDate";

    QNetworkAccessManager* manager = new QNetworkAccessManager();

    QObject::connect(manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(replyFunction(QNetworkReply*)), Qt::UniqueConnection);
    manager->get(request);

}

/*void EventModel::eventsForMonth(const QDate &date) {

}*/
