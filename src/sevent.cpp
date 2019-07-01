#include "sevent.h"

//Responce class

template <class Responce>
ResponceTemplate<Responce>::ResponceTemplate(long cnt, long ofst, long state, bool succ, QString msg, QList<Responce> dat) {
    count = cnt;
    offset = ofst;
    status = state;
    success = succ;
    message = msg;
    data = dat;
}

template <class Responce>
void ResponceTemplate<Responce>::setCount(long cnt) {count = cnt;}
template <class Responce>
long ResponceTemplate<Responce>::getCount() {return count;}

template <class Responce>
void ResponceTemplate<Responce>::setOffset(long ofst) {offset = ofst;}
template <class Responce>
long ResponceTemplate<Responce>::getOffset() {return offset;}

template <class Responce>
void ResponceTemplate<Responce>::setStatus(long stat) {status = stat;}
template <class Responce>
long ResponceTemplate<Responce>::getStatus() {return status;}

template <class Responce>
void ResponceTemplate<Responce>::setSuccess(bool succ) {success = succ;}
template <class Responce>
bool ResponceTemplate<Responce>::getSuccess() {return success;}

template <class Responce>
void ResponceTemplate<Responce>::setMessage(QString msg) {message = msg;}
template <class Responce>
QString ResponceTemplate<Responce>::getMessage() {return message;}

template <class Responce>
void ResponceTemplate<Responce>::setData(QList<Responce> dat) {data = dat;}
template <class Responce>
QList<Responce> ResponceTemplate<Responce>::getData() {return data;}


//Event Class

Event::Event(QString nam, QString dets, QString locn, QString stat) {
    created_at = 0;
    updated_at = 0;
    id = 0;
    owner_id = "";
    name = nam;
    details = dets;
    location = locn;
    status = stat;
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
long Event::getCreationTime() {return created_at;}
long Event::getUpdateTime() {return updated_at;}
long Event::getID() {return id;}


// Event Instance class

EventInstance::EventInstance(long evtid, long patrnid) {
    started_at = 0;
    ended_at = 0;
    event_id = evtid;
    pattern_id = patrnid;
}

void EventInstance::setEventID(long evtid) {event_id = evtid;}
void EventInstance::setPatternID(long patrnid) {pattern_id = patrnid;}

long EventInstance::getStartTime() {return started_at;}
long EventInstance::getEndTime() {return ended_at;}
long EventInstance::getEventID() {return event_id;}
long EventInstance::getPatternID() {return pattern_id;}


//Event Pattern class
EventPattern::EventPattern(long dur, long start, long end, QString exrl, QString rrl, QString tzone) {
    created_at = 0;
    updated_at = 0;
    id = 0;
    started_at = start;
    ended_at = end;
    duration = dur;
    exrule = exrl;
    rrule = rrl;
    timezone = tzone;
};

void EventPattern::setExcRule(QString exrl) {exrule = exrl;}
void EventPattern::setRepRule(QString rrl) {rrule = rrl;}
void EventPattern::setTimeZone(QString tzone) {timezone = tzone;}
void EventPattern::setStartTime(long start) {started_at = start;}
void EventPattern::setEndTime(long end) {ended_at = end;}
void EventPattern::setDuration(long dur) {duration = dur;}


QString EventPattern::getExcRule() {return exrule;}
QString EventPattern::getRepRule() {return rrule;}
QString EventPattern::getTimeZone() {return timezone;}
long EventPattern::getStartTime() {return started_at;}
long EventPattern::getEndTime() {return ended_at;}
long EventPattern::getDuration() {return duration;}
long EventPattern::getCreationTime() {return created_at;}
long EventPattern::getUpdateTime() {return updated_at;}
long EventPattern::getID() {return id;}



