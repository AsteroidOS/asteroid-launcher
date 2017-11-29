TEMPLATE = app
TARGET = asteroid-launcher
VERSION = 0.1

QT += quick waylandcompositor dbus
CONFIG += qt link_pkgconfig qtquickcompiler
PKGCONFIG += lipstick-qt5 timed-qt5

SOURCES += \
    main.cpp \
    applauncherbackground.cpp \
    gesturefilterarea.cpp \
    notificationsnoozer.cpp

HEADERS += \
    applauncherbackground.h \
    gesturefilterarea.h \
    notificationsnoozer.h

RESOURCES += \
    resources-qml.qrc

OTHER_FILES += qml/*.qml \
    qml/MainScreen.qml \
    qml/applauncher/AppLauncher.qml \
    qml/today/Today.qml \
    qml/appswitcher/LauncherItemDelegate.qml \
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

watchfaces.path = /usr/share/asteroid-launcher/watchfaces
watchfaces.files =  watchfaces/*

INSTALLS = target watchfaces
