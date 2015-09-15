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
    qml/Lockscreen.qml \
    qml/LockscreenClock.qml \
    qml/AppSwitcher.qml \
    qml/AppLauncher.qml \
    qml/ToolBarLayoutExample.qml \
    qml/SwitcherItem.qml \
    qml/CloseButton.qml \
    qml/NotificationPreview.qml \
    qml/FeedsPage.qml \
    qml/Statusbar.qml \
    qml/StatusbarItem.qml \
    qml/WifiPanel.qml \
    qml/SimPanel.qml \
    qml/NumButton.qml \
    qml/USBModeSelector.qml \
    qml/Pager.qml \
    qml/VolumeControl.qml \
    qml/BatteryPanel.qml \
    qml/CommonPanel.qml \
    qml/ShutdownScreen.qml \
    qml/LauncherRotation.qml \
    qml/DeviceLock.qml

qmlcompositor.path = /usr/share/asteroid-launcher/qml/compositor
qmlcompositor.files = qml/compositor/WindowWrapperMystic.qml \
    qml/compositor/WindowWrapperBase.qml \
    qml/compositor/WindowWrapperAlpha.qml \
    qml/compositor/ScreenGestureArea.qml

scripts.path = /usr/share/asteroid-launcher/qml/scripts
scripts.files =  qml/scripts/desktop.js \
                qml/scripts/rotation.js

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
    qml/Lockscreen.qml \
    qml/LockscreenClock.qml \
    qml/AppSwitcher.qml \
    qml/AppLauncher.qml \
    qml/ToolBarLayoutExample.qml \
    qml/SwitcherItem.qml \
    qml/CloseButton.qml \
    qml/compositor/WindowWrapperMystic.qml \
    qml/compositor/WindowWrapperBase.qml \
    qml/compositor/WindowWrapperAlpha.qml \
    qml/compositor/ScreenGestureArea.qml \
    qml/NotificationPreview.qml \
    qml/scripts/desktop.js \
    qml/FeedsPage.qml \
    qml/Statusbar.qml \
    qml/StatusbarItem.qml \
    qml/WifiPanel.qml \
	nemovars.conf \
    qml/SimPanel.qml \
    qml/NumButton.qml \
    qml/USBModeSelector.qml \
    qml/VolumeControl.qml \
    qml/BatteryPanel.qml \
    qml/CommonPanel.qml \
    qml/ShutdownScreen.qml \
    qml/LauncherRotation.qml \
    qml/DeviceLock.qml

