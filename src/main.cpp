
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

#include <homeapplication.h>
#include <QFont>
#include <homewindow.h>
#include <lipstickqmlpath.h>
#include <QQmlEngine>
#include <QQmlContext>
#include "glacierwindowmodel.h"

int main(int argc, char **argv)
{
    QmlPath::append("/usr/share/lipstick-glacier-home-qt5/qml");
    HomeApplication app(argc, argv, QString());

    QGuiApplication::setFont(QFont("Open Sans"));
    app.setCompositorPath("/usr/share/lipstick-glacier-home-qt5/qml/compositor.qml");
    qmlRegisterType<GlacierWindowModel>("org.nemomobile.glacier", 1, 0 ,"GlacierWindowModel");
    app.setQmlPath("/usr/share/lipstick-glacier-home-qt5/qml/MainScreen.qml");
    app.mainWindowInstance()->showFullScreen();
    return app.exec();
}

