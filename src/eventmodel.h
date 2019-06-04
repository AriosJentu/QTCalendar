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
        void addEvent(Event &event);
        void removeEvent(Event &event);
        void updateEvent(Event &updatable, Event &update);
        void clearEventsForDate(const QDate &date);

        static void createConnection();
};


#endif // EVENTMODEL_H
