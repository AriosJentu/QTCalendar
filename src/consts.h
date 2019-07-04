#ifndef CONSTS_H
#define CONSTS_H

#include <QString>

namespace Consts {

    const QString srv_location = "http://planner.skillmasters.ga/api/v1/";
    const QString srv_events = srv_location+"events";
    const QString srv_instances = srv_events+"/instances";
    const QString srv_patterns = srv_location+"patterns";

    const QByteArray AuthName = "X-Firebase-Auth";
    const QByteArray AuthToken = "serega_mem";
}

#endif // CONSTS_H
