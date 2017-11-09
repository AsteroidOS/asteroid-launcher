TEMPLATE = app
TARGET = lipstick
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

TRANSLATIONS = i18n/asteroid-launcher.ca.ts \
               i18n/asteroid-launcher.da.ts \
               i18n/asteroid-launcher.de_DE.ts \
               i18n/asteroid-launcher.el.ts \
               i18n/asteroid-launcher.es.ts \
               i18n/asteroid-launcher.fa.ts \
               i18n/asteroid-launcher.fi.ts \
               i18n/asteroid-launcher.fr.ts \
               i18n/asteroid-launcher.hu.ts \
               i18n/asteroid-launcher.it.ts \
               i18n/asteroid-launcher.kab.ts \
               i18n/asteroid-launcher.ko.ts \
               i18n/asteroid-launcher.nl_NL.ts \
               i18n/asteroid-launcher.pl.ts \
               i18n/asteroid-launcher.pt_BR.ts \
               i18n/asteroid-launcher.ru.ts \
               i18n/asteroid-launcher.sv.ts \
               i18n/asteroid-launcher.ta.ts \
               i18n/asteroid-launcher.tr.ts \
               i18n/asteroid-launcher.uk.ts \
               i18n/asteroid-launcher.zh_Hans.ts

target.path = /usr/bin

watchfaces.path = /usr/share/asteroid-launcher/watchfaces
watchfaces.files =  watchfaces/*

INSTALLS = target watchfaces
