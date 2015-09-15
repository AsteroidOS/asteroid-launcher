
// This file is part of colorful-home, a nice user experience for touchscreens.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// Copyright (c) 2012, Timur Kristóf <venemo@fedoraproject.org>

#include <QFont>
#include <QScreen>
#include <QQmlEngine>
#include <QQmlContext>

#include <lipstickqmlpath.h>
#include <homeapplication.h>
#include <homewindow.h>

#include "launcherwindowmodel.h"

int main(int argc, char **argv)
{
    QmlPath::append("/usr/share/asteroid-launcher/qml");
    HomeApplication app(argc, argv, QString());

    QGuiApplication::setFont(QFont("Open Sans"));
    app.setCompositorPath("/usr/share/asteroid-launcher/qml/compositor.qml");
    Qt::ScreenOrientation nativeOrientation = app.primaryScreen()->nativeOrientation();
    QByteArray v = qgetenv("LAUNCHER_NATIVEORIENTATION");
    if (!v.isEmpty()) {
        switch (v.toInt()) {
        case 1:
            nativeOrientation = Qt::PortraitOrientation;
            break;
        case 2:
            nativeOrientation = Qt::LandscapeOrientation;
            break;
        case 4:
            nativeOrientation = Qt::InvertedPortraitOrientation;
            break;
        case 8:
            nativeOrientation = Qt::InvertedLandscapeOrientation;
            break;
        default:
            nativeOrientation = app.primaryScreen()->nativeOrientation();
        }
    }
    if (nativeOrientation == Qt::PrimaryOrientation)
        nativeOrientation = app.primaryScreen()->primaryOrientation();
    app.engine()->rootContext()->setContextProperty("nativeOrientation", nativeOrientation);

    qmlRegisterType<LauncherWindowModel>("org.asteroidproject.launcher", 1, 0 ,"LauncherWindowModel");
    app.setQmlPath("/usr/share/asteroid-launcher/qml/MainScreen.qml");

    // Give these to the environment inside the lipstick homescreen
    // Fixes a bug where some applications wouldn't launch, eg. terminal or browser
    setenv("EGL_PLATFORM", "wayland", 1);
    setenv("QT_QPA_PLATFORM", "wayland", 1);
    setenv("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1", 1);
    app.mainWindowInstance()->showFullScreen();
    return app.exec();
}

