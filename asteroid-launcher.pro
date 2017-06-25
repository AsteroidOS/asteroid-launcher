# Main project file for Asteroid Launcher

TEMPLATE = app
TARGET = lipstick
VERSION = 0.1

INSTALLS = target
target.path = /usr/bin

watchfaces.path = /usr/share/asteroid-launcher/watchfaces
watchfaces.files =  watchfaces/*

qml.path = /usr/share/asteroid-launcher/qml
qml.files = qml/MainScreen.qml \
    qml/compositor.qml \
    qml/LauncherItemDelegate.qml \
    qml/AppSwitcher.qml \
    qml/QuickSettings.qml \
    qml/QuickSettingsToggle.qml \
    qml/AppLauncher.qml \
    qml/FeedsPage.qml \
    qml/USBModeSelector.qml \
    qml/VolumeControl.qml \
    qml/ShutdownScreen.qml

scripts.path = /usr/share/asteroid-launcher/qml/
scripts.files =  qml/desktop.js

qmlcompositor.path = /usr/share/asteroid-launcher/qml/compositor
qmlcompositor.files = qml/compositor/WindowWrapperMystic.qml \
    qml/compositor/WindowWrapperBase.qml \
    qml/compositor/WindowWrapperAlpha.qml

system.path = /usr/share/asteroid-launcher/qml/system
system.files = qml/ShutdownScreen.qml

volumecontrol.path = /usr/share/asteroid-launcher/qml/volumecontrol
volumecontrol.files = qml/VolumeControl.qml

connectivity.path = /usr/share/asteroid-launcher/qml/connectivity
connectivity.files = qml/USBModeSelector.qml \
    qml/ConnectionSelector.qml \
    qml/BluetoothAgent.qml

notifications.path = /usr/share/asteroid-launcher/qml/notifications
notifications.files = qml/NotificationPreview.qml

INSTALLS += qml qmlcompositor scripts system volumecontrol connectivity notifications watchfaces

CONFIG += qt link_pkgconfig
QT += quick waylandcompositor
DEFINES += QT_COMPOSITOR_QUICK
HEADERS += \
    applauncherbackground.h

MOC_DIR = .moc

SOURCES += \
    main.cpp \
    applauncherbackground.cpp

RESOURCES += \
    resources-qml.qrc

PKGCONFIG += lipstick-qt5

OTHER_FILES += qml/*.qml \
    qml/MainScreen.qml \
    qml/compositor.qml \
    qml/LauncherItemDelegate.qml \
    qml/AppSwitcher.qml \
    qml/QuickSettings.qml \
    qml/QuickSettingsToggle.qml \
    qml/AppLauncher.qml \
    qml/compositor/WindowWrapperMystic.qml \
    qml/compositor/WindowWrapperBase.qml \
    qml/compositor/WindowWrapperAlpha.qml \
    qml/NotificationPreview.qml \
    qml/FeedsPage.qml \
    qml/USBModeSelector.qml \
    qml/VolumeControl.qml \
    qml/ShutdownScreen.qml

lupdate_only{
    SOURCES = qml/AppSwitcher.qml \
              qml/FeedsPage.qml
}

TRANSLATIONS = i18n/asteroid-launcher.ca.ts \
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
