#ifndef EVENT_H
#define EVENT_H

#include <QObject>
#include <QDateTime>
#include <QString>

class Event: public QObject {

    Q_OBJECT

    Q_PROPERTY(int id READ getID WRITE setID)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString information READ information WRITE setInfo NOTIFY infoChanged)
    Q_PROPERTY(QDateTime startDate READ startDate WRITE setStartDate NOTIFY startDateChanged)
    Q_PROPERTY(QDateTime endDate READ endDate WRITE setEndDate NOTIFY endDateChanged)
    Q_PROPERTY(QDateTime repeating READ repeats WRITE setRepeating NOTIFY repeatingChanged)

    public:
        explicit Event(QObject* parent = nullptr);

        int getID() const;
        void setID(const int &id);

        QString name() const;
        void setName(const QString &name);

        QString information() const;
        void setInfo(const QString &information);

        QDateTime startDate() const;
        void setStartDate(const QDateTime &startDate);

        QDateTime endDate() const;
        void setEndDate(const QDateTime &endDate);

        QDateTime repeats() const;
        void setRepeating(const QDateTime &repeating);

    private:

        int evtID;
        QString evtName;
        QString evtInformation;
        QDateTime evtStartDate;
        QDateTime evtEndDate;
        QDateTime repeating;

    signals:

        void nameChanged(const QString &name);
        void infoChanged(const QString &information);
        void startDateChanged(const QDateTime &startDate);
        void endDateChanged(const QDateTime &endDate);
        void repeatingChanged(const QDateTime &repeats);

};

#endif // EVENT_H
