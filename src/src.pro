
# Main project file for Glacier home

TEMPLATE = app
TARGET = lipstick
VERSION = 0.1

INSTALLS = target
target.path = /usr/bin

styles.path = /usr/share/lipstick-glacier-home-qt5
styles.files = nemovars.conf

qml.path = /usr/share/lipstick-glacier-home-qt5/qml
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
    qml/BatteryPanel.qml

qmlcompositor.path = /usr/share/lipstick-glacier-home-qt5/qml/compositor
qmlcompositor.files = qml/compositor/WindowWrapperMystic.qml \
    qml/compositor/WindowWrapperBase.qml \
    qml/compositor/WindowWrapperAlpha.qml \
    qml/compositor/ScreenGestureArea.qml

scripts.path = /usr/share/lipstick-glacier-home-qt5/qml/scripts
scripts.files =  qml/scripts/desktop.js

INSTALLS += styles qml qmlcompositor scripts

CONFIG += qt link_pkgconfig
QT += quick compositor
DEFINES += QT_COMPOSITOR_QUICK
HEADERS += \
    glacierwindowmodel.h

MOC_DIR = .moc

SOURCES += \
    main.cpp \
    glacierwindowmodel.cpp

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
    qml/BatteryPanel.qml


