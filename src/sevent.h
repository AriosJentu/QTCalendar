#ifndef SEVENT_H
#define SEVENT_H

#include <QObject>
#include <QDateTime>
#include <QString>
#include <QtNetwork>
#include <QList>


namespace Server {

    template <class Evt>
    QList<Evt*> getEventData(QJsonObject obj);

    qint64 fromDateToTimestamp(QDateTime dat) {return dat.toMSecsSinceEpoch();}
    QDateTime toDateFromTimestamp(qint64 time) {return QDateTime::fromMSecsSinceEpoch(time).toUTC();}
    QDateTime toDateFromTimestamp(QJsonValue val) {return QDateTime::fromMSecsSinceEpoch(val.toVariant().toLongLong()).toUTC();}

    class Response: public QObject {

        qlonglong count;
        qlonglong offset;
        qlonglong status;
        bool success;
        QString message;

        public:

            Response(qlonglong count, qlonglong offset, qlonglong status, bool success, QString message);
            Response(QJsonObject object);

            void setCount(qlonglong count);
            void setOffset(qlonglong offset);
            void setStatus(qlonglong status);
            void setSuccess(bool success);
            void setMessage(QString message);

            qlonglong getCount();
            qlonglong getOffset();
            qlonglong getStatus();
            bool getSuccess();
            QString getMessage();

    };

    class Event: public QObject {

        QDateTime created_at;
        QDateTime updated_at;
        qlonglong id;
        QString owner_id;

        QString details;
        QString location;
        QString name;
        QString status;

        public:

            Event(QString name, QString details, QString location, QString status);
            Event(QJsonObject object);

            void setDetails(QString details);
            void setLocation(QString location);
            void setName(QString name);
            void setStatus(QString status);

            QDateTime getCreationTime();
            QDateTime getUpdateTime();
            qlonglong getID();
            QString getOwnerID();

            QString getDetails();
            QString getLocation();
            QString getName();
            QString getStatus();

    };

    class EventInstance: public QObject {

        QDateTime started_at;
        QDateTime ended_at;

        qlonglong event_id;
        qlonglong pattern_id;

        public:

            EventInstance(qlonglong event_id, qlonglong pattern_id);
            EventInstance(QJsonObject object);

            void setEventID(qlonglong event_id);
            void setPatternID(qlonglong pattern_id);

            QDateTime getStartTime();
            QDateTime getEndTime();
            qlonglong getEventID();
            qlonglong getPatternID();

    };

    class EventPattern: public QObject {

        QDateTime created_at;
        QDateTime updated_at;
        qlonglong id;

        QDateTime started_at;
        QDateTime ended_at;
        qlonglong duration;

        QString exrule;
        QString rrule;
        QString timezone;

        public:

            EventPattern(QDateTime started_at, QDateTime ended_at, qlonglong duration, QString exrule, QString rrule, QString timezone);
            EventPattern(QJsonObject object);

            void setExcRule(QString exrule);
            void setRepRule(QString rrule);
            void setTimeZone(QString timezone);
            void setDuration(qlonglong duration);
            void setStartTime(QDateTime started_at);
            void setEndTime(QDateTime ended_at);

            QDateTime getCreationTime();
            QDateTime getUpdateTime();
            QDateTime getStartTime();
            QDateTime getEndTime();
            qlonglong getID();
            qlonglong getDuration();

            QString getExcRule();
            QString getRepRule();
            QString getTimeZone();

    };

    class EventResponse: public Response {

        QList<Event*> data;

        public:
            explicit EventResponse(qlonglong count, qlonglong offset, qlonglong status, bool success, QString message, QList<Event*> data);
            explicit EventResponse(QJsonObject object);

            void setData(QList<Event*> dat);
            QList<Event*> getData();
    };

    class EventInstanceResponse: public Response {

        QList<EventInstance*> data;

        public:
            explicit EventInstanceResponse(qlonglong count, qlonglong offset, qlonglong status, bool success, QString message, QList<EventInstance*> data);
            explicit EventInstanceResponse(QJsonObject object);

            void setData(QList<EventInstance*> dat);
            QList<EventInstance*> getData();
    };

    class EventPatternResponse: public Response {

        QList<EventPattern*> data;

        public:
            explicit EventPatternResponse(qlonglong count, qlonglong offset, qlonglong status, bool success, QString message, QList<EventPattern*> data);
            explicit EventPatternResponse(QJsonObject object);

            void setData(QList<EventPattern*> dat);
            QList<EventPattern*> getData();
    };
}

#endif // SEVENT_H
