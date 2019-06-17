#ifndef EVENTMODEL_H
#define EVENTMODEL_H

#include <QList>
#include <QObject>
#include <QSqlQuery>
#include "event.h"

class EventModel: public QObject {

    Q_OBJECT

    public:
        EventModel();

        Q_INVOKABLE QList<QObject*> eventsForDate(const QDate &date);
        Q_INVOKABLE void addEvent(const int id, const QString name, const QString info, const QDateTime startDate, const QDateTime endDate);
        Q_INVOKABLE void removeEvent(const int id);
        Q_INVOKABLE void updateEvent(const int updid, const QString newName, const QString newInfo, const QDateTime newStartDate, const QDateTime newEndDate);

        void addEvent(Event &event);
        void removeEvent(Event &event);
        void updateEvent(Event &updatable, Event &update);
        void clearEventsForDate(const QDate &date);

        static void createConnection();


};


#endif // EVENTMODEL_H
