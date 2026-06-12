
// This file is part of lipstick, a QML desktop library
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
//
// Copyright (c) 2012, Timur Kristóf <venemo@fedoraproject.org>

#ifndef LIPSTICKPLUGIN_H
#define LIPSTICKPLUGIN_H

#include <QQmlExtensionPlugin>
#include <QQmlParserStatus>
#include <components/launchermodel.h>
#include <components/launcherfoldermodel.h>

class Q_DECL_EXPORT LipstickPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.nemomobile.lipstick")

public:
    explicit LipstickPlugin(QObject *parent = 0);
    void registerTypes(const char *uri);
    
};

class LauncherModelType : public LauncherModel, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
public:
    explicit LauncherModelType(QObject *parent = 0)
        : LauncherModel(DeferInitialization, parent)
    {
    }

    void classBegin() {}
    void componentComplete() { initialize(); }
};

class LauncherFolderModelType : public LauncherFolderModel, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
public:
    explicit LauncherFolderModelType(QObject *parent = 0)
        : LauncherFolderModel(DeferInitialization, parent)
    {
    }

    void classBegin() {}
    void componentComplete() { initialize(); }
};


#endif // LIPSTICKPLUGIN_H
