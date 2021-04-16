TEMPLATE = app
TARGET = asteroid-launcher
VERSION = 0.1

QT += quick waylandcompositor dbus
CONFIG += qt link_pkgconfig qtquickcompiler
PKGCONFIG += lipstick-qt5 timed-qt5 mlite5

SOURCES += \
    main.cpp \
    applauncherbackground.cpp \
    firstrun.cpp \
    gesturefilterarea.cpp \
    launcherlocalemanager.cpp \
    notificationsnoozer.cpp

HEADERS += \
    applauncherbackground.h \
    firstrun.h \
    gesturefilterarea.h \
    launcherlocalemanager.h \
    notificationsnoozer.h

RESOURCES += \
    resources-qml.qrc

OTHER_FILES += qml/*.qml \
    qml/MainScreen.qml \
    qml/today/Today.qml \
    qml/compositor/compositor.qml \
    qml/compositor/WindowWrapperBase.qml \
    qml/compositor/CircleMaskShader.qml \
    qml/misc/USBModeSelector.qml \
    qml/misc/VolumeControl.qml \
    qml/misc/ShutdownScreen.qml \
    qml/notifications/NotificationPreview.qml \
    qml/notifications/NotificationsPanel.qml \
    qml/quicksettings/QuickSettings.qml \
    qml/quicksettings/QuickSettingsToggle.qml

TRANSLATIONS = $$files(i18n/$$TARGET.*.ts)

target.path = /usr/bin

applauncher.path = /usr/share/asteroid-launcher/applauncher
applauncher.files =  applauncher/*

watchfaces.path = /usr/share/asteroid-launcher/watchfaces
watchfaces.files =  watchfaces/*

watchfaces-img.path = /usr/share/asteroid-launcher/watchfaces-img
watchfaces-img.files =  watchfaces-img/*

INSTALLS = target applauncher watchfaces watchfaces-img
