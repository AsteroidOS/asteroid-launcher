system(qdbusxml2cpp compositor.xml -a lipstickcompositoradaptor -c LipstickCompositorAdaptor -l LipstickCompositor -i lipstickcompositor.h)

INCLUDEPATH += $$PWD

PUBLICHEADERS += \
    $$PWD/lipstickcompositor.h \
    $$PWD/lipstickcompositorwindow.h \
    $$PWD/lipstickcompositorprocwindow.h \
    $$PWD/lipstickcompositoradaptor.h \
    $$PWD/windowmodel.h \

HEADERS += \
    $$PWD/windowpixmapitem.h \
    $$PWD/lipstickrecorder.h \
    $$PWD/asteroidgesturesextension.h

SOURCES += \
    $$PWD/lipstickcompositor.cpp \
    $$PWD/lipstickcompositorwindow.cpp \
    $$PWD/lipstickcompositorprocwindow.cpp \
    $$PWD/lipstickcompositoradaptor.cpp \
    $$PWD/windowmodel.cpp \
    $$PWD/windowpixmapitem.cpp \
    $$PWD/asteroidgesturesextension.cpp

CONFIG += wayland-scanner
WAYLANDSERVERSOURCES += $$PWD/../../wayland-protocols/asteroid-gestures-unstable-v1.xml

DEFINES += QT_COMPOSITOR_QUICK

QT += waylandcompositor

# needed for hardware compositor
QT += quick-private gui-private core-private waylandcompositor-private qml-private
