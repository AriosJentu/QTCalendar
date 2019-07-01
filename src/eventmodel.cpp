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
    query.prepare("SELECT * FROM Events WHERE date(:dateobj) >= date(EventStart) AND date(:dateobj) <= date(EventEnd)");
    query.bindValue(":dateobj", date.toString("yyyy-MM-dd"));

    bool x = query.exec();

    if (!x) {
        qFatal("Query execution failed");
    }

    while (query.next()) {

//        qInfo() << query.value("EventStart") << " " << query.value("EventEnd");

        Event* curevt = new Event(this);
        curevt->setID(query.value("EventID").toInt());
        curevt->setName(query.value("EventName").toString());
        curevt->setInfo(query.value("EventInformation").toString());


        QDateTime startDate, endDate, repeats;
        startDate.setDate(query.value("EventStart").toDate());
        startDate.setTime(query.value("EventStart").toDateTime().time());
        endDate.setDate(query.value("EventEnd").toDate());
        endDate.setTime(query.value("EventEnd").toDateTime().time());
        repeats.setDate(query.value("EventRepeating").toDate());
        repeats.setTime(query.value("EventRepeating").toDateTime().time());

        qInfo() << query.value("EventEnd") << query.value("EventEnd").toDate() << query.value("EventEnd").toDateTime().time();

        curevt->setStartDate(startDate);
        curevt->setEndDate(endDate);
        curevt->setRepeating(repeats);

        events.append(curevt);
    }

//    qInfo() << "Finished searching events" << " " << events;

    return events;
}

void EventModel::addEvent(Event &event) {

    QSqlQuery query;
    query.prepare("INSERT INTO Events (EventName, EventInformation, EventStart, EventEnd, EventRepeating) VALUES (?, ?, ?, ?, ?)");
    query.addBindValue(event.name());
    query.addBindValue(event.information());
    query.addBindValue(event.startDate().toString("yyyy-MM-dd HH:mm:ss"));
    query.addBindValue(event.endDate().toString("yyyy-MM-dd HH:mm:ss"));
    query.addBindValue(event.repeats().toString("yyyy-MM-dd HH:mm:ss"));

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
    query.prepare("UPDATE Events SET EventName = ':name', EventInformation = ':info', EventStart = ':stdate', EventEnd = ':edate', EventRepeating = ':rep' WHERE EventID == :id");
    query.bindValue(":name", update.name());
    query.bindValue(":info", update.information());
    query.bindValue(":stdate", update.startDate().toString("yyyy-MM-dd HH:mm:ss"));
    query.bindValue(":edate", update.endDate().toString("yyyy-MM-dd HH:mm:ss"));
    query.bindValue(":rep", update.repeats().toString("yyyy-MM-dd HH:mm:ss"));
    query.bindValue(":id", updatable.getID());

    if (!query.exec()) {
        qFatal("Update failed");
    }
}

void EventModel::clearEventsForDate(const QDate &date) {

    QSqlQuery query;
    query.prepare("DELETE FROM Events WHERE date(EventStart) == date(:date)");
    query.bindValue(":date", date.toString("yyyy-MM-dd"));

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
        qDebug() << "::: Path created in" << path;
    } else {
        qDebug() << "::: Path exist at" << path;
    }

    QFile database(filePath);
    if (!database.exists()) {
        database.open(QIODevice::WriteOnly);
        database.close();
        qDebug() << "::: Database file created in" << filePath;
        alreadyCreated = true;
    } else {
        qDebug() << "::: Database file exist in" << filePath;
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
                EventEnd Text, \
                EventRepeating Text \
            ) \
        ");
    }
}

void EventModel::recreateDatabase() {
    QString path = QStandardPaths::writableLocation(QStandardPaths::StandardLocation::AppLocalDataLocation);
    path.append( "/assets/");

    QString filePath = path + "localbase.db";
    QDir dir;

    if (!dir.exists(path)) {
        dir.mkpath(path);
    }

    QFile database(filePath);
    if (database.exists()) {
        database.remove();
        qDebug() << "::: Remove database at" << filePath ;
    }

    createConnection();
}

void EventModel::addEvent(const QString name, const QString info, const QDateTime startDate, const QDateTime endDate, const QDateTime repeats) {
    Event evt;
    evt.setName(name);
    evt.setInfo(info);
    evt.setStartDate(startDate);
    evt.setEndDate(endDate);
    evt.setRepeating(repeats);
    addEvent(evt);
}

void EventModel::removeEvent(const int id) {
    Event evt;
    evt.setID(id);
    removeEvent(evt);
}

void EventModel::updateEvent(const int updid, const QString newName, const QString newInfo, const QDateTime newStartDate, const QDateTime newEndDate, const QDateTime repeats) {
    Event updatable;
    updatable.setID(updid);

    Event update;
    update.setName(newName);
    update.setInfo(newInfo);
    update.setStartDate(newStartDate);
    update.setEndDate(newEndDate);
    update.setRepeating(repeats);

    updateEvent(updatable, update);
}
