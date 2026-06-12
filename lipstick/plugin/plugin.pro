TEMPLATE = lib
TARGET = lipstickplugin
VERSION = 0.1

CONFIG += qt plugin link_pkgconfig
QT += core gui qml quick waylandcompositor dbus
PKGCONFIG += mlite6 dsme_dbus_if thermalmanager_dbus_if usb-moded-qt6

INSTALLS = target qmldirfile
qmldirfile.files = qmldir
qmldirfile.path = $$[QT_INSTALL_QML]/org/nemomobile/lipstick
target.path = $$[QT_INSTALL_QML]/org/nemomobile/lipstick

DEPENDPATH += "../src"
INCLUDEPATH += "../src" "../src/utilities" "../src/xtools" "../src/compositor" "../src/qmsystem2"
LIBS += -L"../src" -llipstick-qt6

HEADERS += \
    lipstickplugin.h

SOURCES += \
    lipstickplugin.cpp

OTHER_FILES += \
    qmldir

QMAKE_CXXFLAGS += \
    -g \
    -fPIC \
    -fvisibility=hidden \
    -fvisibility-inlines-hidden

QMAKE_LFLAGS += \
    -pie \
    -rdynamic
