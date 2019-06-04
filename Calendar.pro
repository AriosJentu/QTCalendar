QT += qml quick sql
CONFIG += c++11
TARGER = Calendar

DEFINES += QT_DEPRECATED_WARNINGS

HEADERS += \
    src/event.h \
    src/eventmodel.h

SOURCES += \
        src/event.cpp \
        src/eventmodel.cpp \
        src/main.cpp

RESOURCES += resources.qrc
OTHER_FILES += qml/calendar.qml

qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
