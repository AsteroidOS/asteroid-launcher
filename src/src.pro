
# Main project file for Glacier home

TEMPLATE = app
TARGET = lipstick
VERSION = 0.1

INSTALLS = target
target.path = /usr/bin

CONFIG += qt link_pkgconfig
QT += quick

HEADERS +=

SOURCES += \
    main.cpp \
    main.cpp

RESOURCES += \
    resources-qml.qrc \
    resources-images.qrc \
    resources-qml.qrc

PKGCONFIG += lipstick-qt5

OTHER_FILES += qml/*.qml \
    qml/MainScreen.qml \
    qml/compositor.qml \
    qml/LauncherItemDelegate.qml \
    qml/Lockscreen.qml \
    qml/LockscreenClock.qml \
    qml/AppSwitcher.qml \
    qml/AppLauncher.qml

config.files = lipstick.conf
config.path = /usr/share/lipstick
INSTALLS += config

