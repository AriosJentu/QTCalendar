#include "eventmodel.h"
#include <QSqlError>
#include <QSqlQuery>
#include <QDebug>
#include <QStandardPaths>
#include <QDir>
#include <QDateTime>

EventModel::EventModel() {
    //createConnection();
}

QList<QObject*> EventModel::eventsForDate(const QDate &date) {

    QList<QObject*> events;

    QSqlQuery query;
    query.prepare("SELECT * FROM Events WHERE date(':dateobj') >= date(EventStart) AND date(':dateobj') <= date(EventEnd)");
    query.bindValue(":dateobj", date.toString("yyyy-MM-dd"));

    bool x = query.exec();

    if (!x) {
        qFatal("Query execution failed");
    }

    while (query.next()) {

//        qInfo() << query.value("EventStart") << " " << query.value("EventEnd");

        Event* curevt = new Event(this);
        curevt->setName(query.value("EventName").toString());
        curevt->setInfo(query.value("EventInformation").toString());


        QDateTime startDate, endDate;
        startDate.setDate(query.value("EventStart").toDate());
        startDate.setTime(query.value("EventStart").toDateTime().time());
        endDate.setDate(query.value("EventEnd").toDate());
        endDate.setTime(query.value("EventEnd").toDateTime().time());

        qInfo() << query.value("EventEnd") << query.value("EventEnd").toDate() << query.value("EventEnd").toDateTime().time();

        curevt->setStartDate(startDate);
        curevt->setEndDate(endDate);

        events.append(curevt);
    }

//    qInfo() << "Finished searching events" << " " << events;

    return events;
}

void EventModel::addEvent(Event &event) {

    QSqlQuery query;
    query.prepare("INSERT INTO Events (EventName, EventInformation, EventStart, EventEnd) VALUES (?, ?, ?, ?)");
    query.addBindValue(event.name());
    query.addBindValue(event.information());
    query.addBindValue(event.startDate().toString("yyyy-MM-dd HH:mm:ss"));
    query.addBindValue(event.endDate().toString("yyyy-MM-dd HH:mm:ss"));

    qInfo() << "::: Adding event";

    bool b = query.exec();
    qInfo() << query.executedQuery();

    if (!b) {
        qFatal("Insert failed");
    } else {

        qInfo() << "::: Data insert";
    }

}

void EventModel::removeEvent(Event &event) {

    QSqlQuery query;
    query.prepare("DELETE FROM Events WHERE EventID == :id");
    query.bindValue(":id", event.getID());

    if (!query.exec()) {
        qFatal("Delete failed");
    }
}

void EventModel::updateEvent(Event &updatable, Event &update) {

    QSqlQuery query;
    query.prepare("UPDATE Events SET EventName = ':name', EventInformation = ':info', EventStart = ':stdate', EventEnd = ':edate' WHERE EventID == :id");
    query.bindValue(":name", update.name());
    query.bindValue(":info", update.information());
    query.bindValue(":stdate", update.startDate().toString("yyyy-MM-dd HH:mm:ss"));
    query.bindValue(":edate", update.endDate().toString("yyyy-MM-dd HH:mm:ss"));
    query.bindValue(":id", updatable.getID());

    if (!query.exec()) {
        qFatal("Update failed");
    }
}

void EventModel::clearEventsForDate(const QDate &date) {

    QSqlQuery query;
    query.prepare("DELETE FROM Events WHERE date(EventStart) == :date");
    query.bindValue(":id", date.toString("yyyy-MM-dd"));

    if (!query.exec()) {
        qFatal("Clearing failed");
    }

}

void EventModel::createConnection() {

    QString path = QStandardPaths::writableLocation(QStandardPaths::StandardLocation::AppLocalDataLocation);
    path.append( "/assets/");

    QString filePath = path + "localbase.db";
    QDir dir;
    bool alreadyCreated = false;

    if (!dir.exists(path)) {
        dir.mkpath(path);
        qDebug() << "::: Path created in " << path;
    }

    QFile database(filePath);
    if (!database.exists()) {
        database.open(QIODevice::WriteOnly);
        database.close();
        qDebug() << "::: File created in " << filePath;
        alreadyCreated = true;
    }

    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(filePath);

    if (!db.open()) {
        qFatal("Database not found");
    }

    if (alreadyCreated) {
        QSqlQuery query;
        query.exec("\
            Create Table `Events` (\
                EventID Integer Primary Key autoincrement,\
                EventName Text default 'Event',\
                EventInformation Text default 'Event Information',\
                EventStart Text, \
                EventEnd Text\
            ) \
        ");
    }
}
