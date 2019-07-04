#ifndef SEVENTMODEL_H
#define SEVENTMODEL_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include "sevent.h"

namespace Server {

    class EventView: public QObject {

        Q_OBJECT

        Q_PROPERTY(qlonglong id READ getID WRITE setID NOTIFY idChanged)
        Q_PROPERTY(qlonglong ptrnid READ getPatternID WRITE setPatternID NOTIFY ptrnidChanged)
        Q_PROPERTY(QDateTime startTime READ getStartTime WRITE setStartTime NOTIFY startChanged)
        Q_PROPERTY(QDateTime endTime READ getEndTime WRITE setEndTime NOTIFY endChanged)
        Q_PROPERTY(QString name READ getName WRITE setName NOTIFY nameChanged)
        Q_PROPERTY(QString details READ getDetails WRITE setDetails NOTIFY detailsChanged)
        Q_PROPERTY(QString location READ getLocation WRITE setLocation NOTIFY locationChanged)
        Q_PROPERTY(QString owner READ getOwner WRITE setOwner NOTIFY ownerChanged)

        qlonglong id;
        qlonglong pattern_id;
        QDateTime start_time;
        QDateTime end_time;
        QString name;
        QString details;
        QString owner_id;
        QString location;

        public:

            EventView(EventInstance* instance);

            qlonglong getID() {return id;}
            qlonglong getPatternID() {return pattern_id;}
            QDateTime getStartTime() {return start_time;}
            QDateTime getEndTime() {return end_time;}
            QString getName() {return name;}
            QString getDetails() {return details;}
            QString getLocation() {return location;}
            QString getOwner() {return owner_id;}

            void setID(qlonglong id) {this->id = id;}
            void setPatternID(qlonglong id) {pattern_id = id;}
            void setStartTime(QDateTime start) {start_time = start;}
            void setEndTime(QDateTime end) {end_time = end;}
            void setName(QString name) {this->name = name;}
            void setDetails(QString details) {this->details = details;}
            void setLocation(QString location) {this->location = location;}
            void setOwner(QString owner) {owner_id = owner;}

        signals:

            void idChanged(const qlonglong &id);
            void ptrnidChanged(const qlonglong &ptrnid);
            void startChanged(const QDateTime &start);
            void endChanged(const QDateTime &end);
            void nameChanged(const QString &name);
            void detailsChanged(const QString &details);
            void locationChanged(const QString &location);
            void ownerChanged(const QString &owner);

        public slots:

            void replyEventFunction(QNetworkReply* reply);

    };

    class EventModel: public QObject {

        Q_OBJECT

        public:

            EventModel();

            Q_INVOKABLE void eventsForDate(const QDate &date);
            //Q_INVOKABLE void eventsForMonth(const QDate &date);
            /*Q_INVOKABLE void getEventByID(const qlonglong id);
            Q_INVOKABLE void addEvent(QObject* event);
            Q_INVOKABLE void removeEvent(QObject* event);
            Q_INVOKABLE void updateEvent(QObject* event);
            Q_SIGNAL void eventAvailable(QObject* &result);
            Q_INVOKABLE QObject* createEvent();*/
            Q_SIGNAL void eventsAvailable(const QList<QObject*> &result);

            void addEvent(Event &event);
            void removeEvent(Event &event);
            void updateEvent(Event &event);

        public slots:

            void replyFunction(QNetworkReply* reply);

    };

}

#endif // SEVENTMODEL_H
