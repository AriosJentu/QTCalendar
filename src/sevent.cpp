#include "sevent.h"

template <class Evt>
QList<Evt*> Server::getEventData(QJsonObject obj) {
    QList<Evt*> data;
    QJsonArray data_arr = obj["data"].toArray();
    qDebug() << "!::::! Count: " << data_arr.count();

    for (int i = 0; i < data_arr.count(); i++) {

        QJsonObject val = data_arr[i].toObject();
        Evt* evt = new Evt(val);
        data.append(evt);
    }

    return data;
}

using namespace Server;

//Response class

Response::Response(qlonglong cnt, qlonglong ofst, qlonglong state, bool succ, QString msg) {
    count = cnt;
    offset = ofst;
    status = state;
    success = succ;
    message = msg;
}
Response::Response(QJsonObject dat) {
    count = dat["count"].toVariant().toLongLong();
    offset = dat["offset"].toVariant().toLongLong();
    status = dat["status"].toVariant().toLongLong();
    success = dat["success"].toBool();
    message = dat["message"].toString();
}

void Response::setCount(qlonglong cnt) {count = cnt;}
void Response::setOffset(qlonglong ofst) {offset = ofst;}
void Response::setStatus(qlonglong stat) {status = stat;}
void Response::setSuccess(bool succ) {success = succ;}
void Response::setMessage(QString msg) {message = msg;}

qlonglong Response::getCount() {return count;}
qlonglong Response::getOffset() {return offset;}
qlonglong Response::getStatus() {return status;}
bool Response::getSuccess() {return success;}
QString Response::getMessage() {return message;}


//Event Class

Event::Event(QString nam, QString dets, QString locn, QString stat) {
    id = 0;
    owner_id = "";
    name = nam;
    details = dets;
    location = locn;
    status = stat;
}
Event::Event(QJsonObject dat) {
    created_at = toDateFromTimestamp(dat["created_at"]);
    updated_at = toDateFromTimestamp(dat["updated_at"]);
    id = dat["id"].toVariant().toLongLong();
    owner_id = dat["owner_id"].toString();
    name = dat["name"].toString();
    details = dat["details"].toString();
    location = dat["location"].toString();
    status = dat["status"].toString();
}

void Event::setDetails(QString dets) {details = dets;}
void Event::setLocation(QString locn) {location = locn;}
void Event::setName(QString nam) {name = nam;}
void Event::setStatus(QString stat) {status = stat;}

QString Event::getDetails() {return details;}
QString Event::getLocation() {return location;}
QString Event::getName() {return name;}
QString Event::getStatus() {return status;}
QString Event::getOwnerID() {return owner_id;}
QDateTime Event::getCreationTime() {return created_at;}
QDateTime Event::getUpdateTime() {return updated_at;}
qlonglong Event::getID() {return id;}


// Event Instance class

EventInstance::EventInstance(qlonglong evtid, qlonglong patrnid) {
    event_id = evtid;
    pattern_id = patrnid;
}
EventInstance::EventInstance(QJsonObject dat) {
    started_at = toDateFromTimestamp(dat["started_at"]);
    ended_at = toDateFromTimestamp(dat["ended_at"]);
    event_id = dat["event_id"].toVariant().toLongLong();
    pattern_id = dat["pattern_id"].toVariant().toLongLong();
}

void EventInstance::setEventID(qlonglong evtid) {event_id = evtid;}
void EventInstance::setPatternID(qlonglong patrnid) {pattern_id = patrnid;}

QDateTime EventInstance::getStartTime() {return started_at;}
QDateTime EventInstance::getEndTime() {return ended_at;}
qlonglong EventInstance::getEventID() {return event_id;}
qlonglong EventInstance::getPatternID() {return pattern_id;}


//Event Pattern class

EventPattern::EventPattern(QDateTime start, QDateTime end, qlonglong dur, QString exrl, QString rrl, QString tzone) {
    started_at = start;
    ended_at = end;
    duration = dur;
    id = 0;
    exrule = exrl;
    rrule = rrl;
    timezone = tzone;
};
EventPattern::EventPattern(QJsonObject dat) {
    created_at = toDateFromTimestamp(dat["created_at"]);
    updated_at = toDateFromTimestamp(dat["updated_at"]);
    started_at = toDateFromTimestamp(dat["started_at"]);
    ended_at = toDateFromTimestamp(dat["ended_at"]);
    id = dat["id"].toVariant().toLongLong();
    duration = dat["duration"].toVariant().toLongLong();
    exrule = dat["exrule"].toString();
    rrule = dat["rrule"].toString();
    timezone = dat["timezone"].toString();
}

void EventPattern::setExcRule(QString exrl) {exrule = exrl;}
void EventPattern::setRepRule(QString rrl) {rrule = rrl;}
void EventPattern::setTimeZone(QString tzone) {timezone = tzone;}
void EventPattern::setStartTime(QDateTime start) {started_at = start;}
void EventPattern::setEndTime(QDateTime end) {ended_at = end;}
void EventPattern::setDuration(qlonglong dur) {duration = dur;}

QString EventPattern::getExcRule() {return exrule;}
QString EventPattern::getRepRule() {return rrule;}
QString EventPattern::getTimeZone() {return timezone;}
QDateTime EventPattern::getStartTime() {return started_at;}
QDateTime EventPattern::getEndTime() {return ended_at;}
QDateTime EventPattern::getCreationTime() {return created_at;}
QDateTime EventPattern::getUpdateTime() {return updated_at;}
qlonglong EventPattern::getDuration() {return duration;}
qlonglong EventPattern::getID() {return id;}

/*
template <class Evt> ResponseData<Evt>::ResponseData(qlonglong cnt, qlonglong ofst, qlonglong stat, bool succ, QString msg, QList<Evt*> dat) : Response(cnt, ofst, stat, succ, msg) {
    data = dat;
}
template <class Evt> ResponseData<Evt>::ResponseData(QJsonObject obj) : Response(obj) {

    QJsonArray data_arr = obj["data"].toArray();

    for (int i = 0; i > data_arr.count(); i++) {

        QJsonObject val = data_arr[i].toObject();
        Evt* evt = new Evt(val);
        data.append(evt);
    }
}

template <class Evt> void ResponseData<Evt>::setData(QList<Evt*> dat) {data = dat;}
template <class Evt> QList<Evt*> ResponseData<Evt>::getData() {return data;}
*/

EventResponse::EventResponse(qlonglong cnt, qlonglong ofst, qlonglong stat, bool succ, QString msg, QList<Event*> dat) : Response(cnt, ofst, stat, succ, msg) {data = dat;};
EventResponse::EventResponse(QJsonObject obj) : Response(obj) {data = getEventData<Event>(obj);};
void EventResponse::setData(QList<Event*> dat) {data = dat;};
QList<Event*> EventResponse::getData() {return data;};

EventInstanceResponse::EventInstanceResponse(qlonglong cnt, qlonglong ofst, qlonglong stat, bool succ, QString msg, QList<EventInstance*> dat) : Response(cnt, ofst, stat, succ, msg) {data = dat;};
EventInstanceResponse::EventInstanceResponse(QJsonObject obj) : Response(obj) {data = getEventData<EventInstance>(obj);};
void EventInstanceResponse::setData(QList<EventInstance*> dat) {data = dat;};
QList<EventInstance*> EventInstanceResponse::getData() {return data;};

EventPatternResponse::EventPatternResponse(qlonglong cnt, qlonglong ofst, qlonglong stat, bool succ, QString msg, QList<EventPattern*> dat) : Response(cnt, ofst, stat, succ, msg) {data = dat;};
EventPatternResponse::EventPatternResponse(QJsonObject obj) : Response(obj) {data = getEventData<EventPattern>(obj);};
void EventPatternResponse::setData(QList<EventPattern*> dat) {data = dat;};
QList<EventPattern*> EventPatternResponse::getData() {return data;};
