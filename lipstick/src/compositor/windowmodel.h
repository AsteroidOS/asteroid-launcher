/***************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Aaron Kennedy <aaron.kennedy@jollamobile.com>
**
** This file is part of lipstick.
**
** This library is free software; you can redistribute it and/or
** modify it under the terms of the GNU Lesser General Public
** License version 2.1 as published by the Free Software Foundation
** and appearing in the file LICENSE.LGPL included in the packaging
** of this file.
**
****************************************************************************/

#ifndef WINDOWMODEL_H
#define WINDOWMODEL_H

#include "lipstickdbus.h"
#include "lipstickglobal.h"
#include <QQmlParserStatus>
#include <QAbstractListModel>

class LipstickCompositor;
class LipstickCompositorWindow;
class LIPSTICK_EXPORT WindowModel : public QAbstractListModel,
                                    public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
    Q_CLASSINFO("D-Bus Interface", LIPSTICK_DBUS_WINDOW_MODEL_INTERFACE)
    Q_PROPERTY(int itemCount READ itemCount NOTIFY itemCountChanged)

public:
    WindowModel();
    ~WindowModel();

    int itemCount() const;
    Q_INVOKABLE int windowId(int) const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role) const;
    QHash<int, QByteArray> roleNames() const;

signals:
    void itemCountChanged();
    void itemAdded(int index);

protected:
    virtual void classBegin();
    virtual void componentComplete();

    virtual bool approveWindow(LipstickCompositorWindow *);

public slots:
    void launchProcess(const QString &binaryName);

private:
    friend class LipstickCompositor;
    void setCompositor(LipstickCompositor *);

    void addItem(int);
    void remItem(int);
    void titleChanged(int);

    void refresh();

    bool m_complete:1;
    QList<int> m_items;
};

#endif // WINDOWMODEL_H
