# Main project file for Asteroid Launcher

TEMPLATE = app
TARGET = lipstick
VERSION = 0.1

INSTALLS = target
target.path = /usr/bin

styles.path = /usr/share/asteroid-launcher/
styles.files = vars.conf

qml.path = /usr/share/asteroid-launcher/qml
qml.files = qml/MainScreen.qml \
    qml/compositor.qml \
    qml/LauncherItemDelegate.qml \
    qml/AppSwitcher.qml \
    qml/QuickSettings.qml \
    qml/AppLauncher.qml \
    qml/SwitcherItem.qml \
    qml/FeedsPage.qml \
    qml/USBModeSelector.qml \
    qml/VolumeControl.qml \
    qml/ShutdownScreen.qml \
    qml/LauncherRotation.qml \
    qml/ClockPage.qml

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
    qml/ConnectionSelector.qml

notifications.path = /usr/share/asteroid-launcher/qml/notifications
notifications.files = qml/NotificationPreview.qml

INSTALLS += styles qml qmlcompositor scripts system volumecontrol connectivity notifications

CONFIG += qt link_pkgconfig
QT += quick compositor
DEFINES += QT_COMPOSITOR_QUICK
HEADERS += \
    launcherwindowmodel.h

MOC_DIR = .moc

SOURCES += \
    main.cpp \
    launcherwindowmodel.cpp

RESOURCES += \
    resources-qml.qrc

PKGCONFIG += lipstick-qt5

OTHER_FILES += qml/*.qml \
    qml/MainScreen.qml \
    qml/compositor.qml \
    qml/LauncherItemDelegate.qml \
    qml/AppSwitcher.qml \
    qml/QuickSettings.qml \
    qml/AppLauncher.qml \
    qml/SwitcherItem.qml \
    qml/compositor/WindowWrapperMystic.qml \
    qml/compositor/WindowWrapperBase.qml \
    qml/compositor/WindowWrapperAlpha.qml \
    qml/NotificationPreview.qml \
    qml/FeedsPage.qml \
	vars.conf \
    qml/USBModeSelector.qml \
    qml/VolumeControl.qml \
    qml/ShutdownScreen.qml \
    qml/LauncherRotation.qml \
    qml/ClockPage.qml

