#ifndef SEVENT_H
#define SEVENT_H

#include <QObject>
#include <QDateTime>
#include <QString>
#include <QtNetwork>

template <class Responce>
class ResponceTemplate: public QObject {

    long count;
    long offset;
    long status;
    bool success;
    QString message;
    QList<Responce> data;

    public:

        ResponceTemplate<Responce>(long count, long offset, long status, bool success, QString message, QList<Responce> data);

        void setCount(long count);
        void setOffset(long offset);
        void setStatus(long status);
        void setSuccess(bool success);
        void setMessage(QString message);
        void setData(QList<Responce> data);

        long getCount();
        long getOffset();
        long getStatus();
        bool getSuccess();
        QString getMessage();
        QList<Responce> getData();

};

class Event: public QObject {

    long created_at;
    long updated_at;
    long id;
    QString owner_id;

    QString details;
    QString location;
    QString name;
    QString status;

    public:

        Event(QString name, QString details, QString location, QString status);

        void setDetails(QString details);
        void setLocation(QString location);
        void setName(QString name);
        void setStatus(QString status);

        long getCreationTime();
        long getUpdateTime();
        long getID();
        QString getOwnerID();

        QString getDetails();
        QString getLocation();
        QString getName();
        QString getStatus();

};

class EventInstance: public QObject {

    long started_at;
    long ended_at;

    long event_id;
    long pattern_id;

    public:

        EventInstance(long event_id, long pattern_id);

        void setEventID(long event_id);
        void setPatternID(long pattern_id);

        long getStartTime();
        long getEndTime();
        long getEventID();
        long getPatternID();

};

class EventPattern: public QObject {

    long created_at;
    long updated_at;
    long id;

    long started_at;
    long ended_at;
    long duration;

    QString exrule;
    QString rrule;
    QString timezone;

    public:

        EventPattern(long duration, long started_at, long ended_at, QString exrule, QString rrule, QString timezone);

        void setExcRule(QString exrule);
        void setRepRule(QString rrule);
        void setTimeZone(QString timezone);
        void setDuration(long duration);
        void setStartTime(long started_at);
        void setEndTime(long ended_at);

        long getCreationTime();
        long getUpdateTime();
        long getStartTime();
        long getEndTime();
        long getID();
        long getDuration();

        QString getExcRule();
        QString getRepRule();
        QString getTimeZone();

};

class EventResponce: public ResponceTemplate<Event>{};
class EventInstanceResponce: public ResponceTemplate<EventInstance>{};
class EventPatternResponce: public ResponceTemplate<EventPattern>{};


#endif // SEVENT_H
