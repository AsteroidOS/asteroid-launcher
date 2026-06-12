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


#ifndef LIPSTICK_QML_PATH_H
#define LIPSTICK_QML_PATH_H

#include <QString>
#include <QUrl>

#include "lipstickglobal.h"

class LIPSTICK_EXPORT QmlPath {
public:
    /*!
     * Add a new path to the Lipstick QML search path
     *
     * Paths added this way will be searched after all other paths.
     *
     * \param path The directory name where to search for QML files
     */
    static void append(const QString &path);

    /*!
     * Prepend a new path to the Lipstick QML search path
     *
     * Paths added this way will be searched before all other paths.
     *
     * \param path The directory name where to search for QML files
     */
    static void prepend(const QString &path);

    /*!
     * Resolve the path of a QML file
     *
     * \param filename The basename of a QML file to resolve
     * \return A QUrl to the full path of the file (or an empty QUrl if not found)
     */
    static QUrl to(const QString &filename);
};

#endif /* LIPSTICK_QML_PATH_H */
