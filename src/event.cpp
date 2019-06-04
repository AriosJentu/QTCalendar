#include "event.h"

Event::Event(QObject* parent): QObject(parent) {}

//Event id
int Event::getID() const {
    return evtID;
}

void Event::setID(const int &id) {
    if (id != evtID) {
        evtID = id;
    }
}

//Event Name
QString Event::name() const {
    return evtName;
}

void Event::setName(const QString &name) {
    if (name != evtName) {
        evtName = name;
        emit nameChanged(evtName);
    }
}

//Event information

QString Event::information() const {
    return evtInformation;
}

void Event::setInfo(const QString &information) {
    if (information != evtInformation) {
        evtInformation = information;
        emit infoChanged(evtInformation);
    }
}

//Event start date

QDateTime Event::startDate() const {
    return evtStartDate;
}

void Event::setStartDate(const QDateTime &startDate) {
    if (startDate != evtStartDate) {
        evtStartDate = startDate;
        emit startDateChanged(evtStartDate);
    }
}

//Event end date

QDateTime Event::endDate() const {
    return evtEndDate;
}

void Event::setEndDate(const QDateTime &endDate) {
    if (endDate != evtEndDate) {
        evtEndDate = endDate;
        emit endDateChanged(evtEndDate);
    }
}



