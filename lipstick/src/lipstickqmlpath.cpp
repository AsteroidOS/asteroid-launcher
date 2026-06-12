// This file is part of lipstick, a QML desktop library
//
// Copyright (c) 2014 Jolla Ltd.
// Contact: Thomas Perl <thomas.perl@jolla.com>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License version 2.1 as published by the Free Software Foundation
// and appearing in the file LICENSE.LGPL included in the packaging
// of this file.
//
// This code is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.


#include "lipstickqmlpath.h"

#include <QFile>
#include <QDebug>


// Private list of paths
static QStringList g_paths;


void QmlPath::append(const QString &path)
{
    g_paths.append(path);
}

void QmlPath::prepend(const QString &path)
{
    g_paths.prepend(path);
}

QUrl QmlPath::to(const QString &filename)
{
    if (g_paths.isEmpty()) {
        // Add default search path to not break homescreens that are not
        // aware of the new QmlPath::append()/QmlPath::prepend() API.
        const QString FALLBACK_PATH = ":/qml";
        qWarning() << "Your homescreen does not use the Lipstick QmlPath API.";
        qWarning() << "Using qrc:/ fallback; consider using QmlPath::append()";
        g_paths.append(FALLBACK_PATH);
    }

    for (auto &dir: g_paths) {
        QString fn = dir + "/" + filename;
        if (QFile(fn).exists()) {
            if (fn.startsWith(":")) {
                return QUrl("qrc" + fn);
            } else {
                return QUrl::fromLocalFile(fn);
            }
        }
    }

    qWarning() << "QML file not found:" << filename;
    qWarning() << "QML search path:" << g_paths;
    return QUrl();
}
