TEMPLATE = app
TARGET = lipstick
VERSION = 0.1

INSTALLS = target
target.path = /usr/bin

watchfaces.path = /usr/share/asteroid-launcher/watchfaces
watchfaces.files =  watchfaces/*

qml.path = /usr/share/asteroid-launcher/qml
qml.files = qml/MainScreen.qml \
    qml/applauncher/AppLauncher.qml \
    qml/applauncher/LauncherItemDelegate.qml \
    qml/today/Today.qml \
    qml/compositor/compositor.qml \
    qml/misc/PanelsGrid.qml \
    qml/misc/USBModeSelector.qml \
    qml/misc/VolumeControl.qml \
    qml/misc/ShutdownScreen.qml \
    qml/notifications/NotificationActions.qml \
    qml/notifications/NotificationButton.qml \
    qml/notifications/NotificationIndicator.qml \
    qml/notifications/NotificationView.qml \
    qml/notifications/NotificationsPanel.qml \
    qml/quicksettings/QuickSettings.qml \
    qml/quicksettings/QuickSettingsToggle.qml

scripts.path = /usr/share/asteroid-launcher/qml/
scripts.files =  qml/misc/desktop.js \
    qml/today/weathericons.js

qmlcompositor.path = /usr/share/asteroid-launcher/qml/compositor
qmlcompositor.files = qml/compositor/WindowWrapperBase.qml \
                      qml/compositor/CircleMaskShader.qml

system.path = /usr/share/asteroid-launcher/qml/system
system.files = qml/misc/ShutdownScreen.qml

volumecontrol.path = /usr/share/asteroid-launcher/qml/volumecontrol
volumecontrol.files = qml/misc/VolumeControl.qml

connectivity.path = /usr/share/asteroid-launcher/qml/connectivity
connectivity.files = qml/misc/USBModeSelector.qml \
    qml/misc/ConnectionSelector.qml \
    qml/misc/BluetoothAgent.qml

notifications.path = /usr/share/asteroid-launcher/qml/notifications
notifications.files = qml/notifications/NotificationPreview.qml

INSTALLS += qml qmlcompositor scripts system volumecontrol connectivity notifications watchfaces

CONFIG += qt link_pkgconfig
QT += quick waylandcompositor dbus
DEFINES += QT_COMPOSITOR_QUICK
HEADERS += \
    applauncherbackground.h \
    gesturefilterarea.h \
    notificationsnoozer.h

MOC_DIR = .moc

SOURCES += \
    main.cpp \
    applauncherbackground.cpp \
    gesturefilterarea.cpp \
    notificationsnoozer.cpp

RESOURCES += \
    resources-qml.qrc

PKGCONFIG += lipstick-qt5 timed-qt5

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
