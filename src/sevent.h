#ifndef SEVENT_H
#define SEVENT_H

#include <QObject>
#include <QDateTime>
#include <QString>
#include <QtNetwork>
#include <QList>

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

class ServerEvent: public QObject {

    qlonglong created_at;
    qlonglong updated_at;
    qlonglong id;
    QString owner_id;

    QString details;
    QString location;
    QString name;
    QString status;

    public:

        ServerEvent(QString name, QString details, QString location, QString status);
        ServerEvent(QJsonObject object);

        void setDetails(QString details);
        void setLocation(QString location);
        void setName(QString name);
        void setStatus(QString status);

        qlonglong getCreationTime();
        qlonglong getUpdateTime();
        qlonglong getID();
        QString getOwnerID();

        QString getDetails();
        QString getLocation();
        QString getName();
        QString getStatus();

};

class EventInstance: public QObject {

    qlonglong started_at;
    qlonglong ended_at;

    qlonglong event_id;
    qlonglong pattern_id;

    public:

        EventInstance(qlonglong event_id, qlonglong pattern_id);
        EventInstance(QJsonObject object);

        void setEventID(qlonglong event_id);
        void setPatternID(qlonglong pattern_id);

        qlonglong getStartTime();
        qlonglong getEndTime();
        qlonglong getEventID();
        qlonglong getPatternID();

};

class EventPattern: public QObject {

    qlonglong created_at;
    qlonglong updated_at;
    qlonglong id;

    qlonglong started_at;
    qlonglong ended_at;
    qlonglong duration;

    QString exrule;
    QString rrule;
    QString timezone;

    public:

        EventPattern(qlonglong duration, qlonglong started_at, qlonglong ended_at, QString exrule, QString rrule, QString timezone);
        EventPattern(QJsonObject object);

        void setExcRule(QString exrule);
        void setRepRule(QString rrule);
        void setTimeZone(QString timezone);
        void setDuration(qlonglong duration);
        void setStartTime(qlonglong started_at);
        void setEndTime(qlonglong ended_at);

        qlonglong getCreationTime();
        qlonglong getUpdateTime();
        qlonglong getStartTime();
        qlonglong getEndTime();
        qlonglong getID();
        qlonglong getDuration();

        QString getExcRule();
        QString getRepRule();
        QString getTimeZone();

};

template <class Evt>
class ResponseData: public Response {

    QList<Evt*> data;

    public:
        explicit ResponseData(qlonglong count, qlonglong offset, qlonglong status, bool success, QString message, QList<Evt*> data);
        explicit ResponseData(QJsonObject object);

        void setData(QList<Evt*> data);
        QList<Evt*> getData();

};

class EventResponse: public ResponseData<ServerEvent> {
    public:
        explicit EventResponse(qlonglong count, qlonglong offset, qlonglong status, bool success, QString message, QList<ServerEvent*> data);
        explicit EventResponse(QJsonObject object);
};

class EventInstanceResponse: public ResponseData<EventInstance> {
    public:
        explicit EventInstanceResponse(qlonglong count, qlonglong offset, qlonglong status, bool success, QString message, QList<EventInstance*> data);
        explicit EventInstanceResponse(QJsonObject object);
};

class EventPatternResponse: public ResponseData<EventPattern> {
    public:
        explicit EventPatternResponse(qlonglong count, qlonglong offset, qlonglong status, bool success, QString message, QList<EventPattern*> data);
        explicit EventPatternResponse(QJsonObject object);
};

#endif // SEVENT_H
