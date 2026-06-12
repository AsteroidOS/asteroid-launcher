system(qdbusxml2cpp ../../src/notifications/notificationmanager.xml -p notificationmanagerproxy -c NotificationManagerProxy -i lipsticknotification.h)

TEMPLATE = app
TARGET = notificationtool

QT += core dbus
CONFIG += link_pkgconfig
PKGCONFIG += mlite6 dsme_dbus_if thermalmanager_dbus_if usb_moded

INSTALLS = target
target.path = /usr/bin

DEPENDPATH += "../../src"
INCLUDEPATH += "../../src" "../../src/notifications" "../../src/qmsystem2"
QMAKE_LIBDIR = ../../src
LIBS = -llipstick-qt6

HEADERS += \
     notificationmanagerproxy.h
SOURCES += \
     notificationtool.cpp \
     notificationmanagerproxy.cpp

QMAKE_CXXFLAGS += \
    -g \
    -fvisibility=hidden \
    -fvisibility-inlines-hidden
