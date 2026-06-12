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

#ifndef WINDOWPIXMAPITEM_H
#define WINDOWPIXMAPITEM_H

#include <QWaylandQuickItem>
#include "lipstickapi.h"

class LIPSTICK_EXPORT WindowPixmapItem : public QWaylandQuickItem
{
    Q_OBJECT
    Q_PROPERTY(int windowId READ windowId WRITE setWindowId NOTIFY windowIdChanged)

public:
    WindowPixmapItem();
    ~WindowPixmapItem();

    int windowId() const;
    void setWindowId(int);

signals:
    void windowIdChanged();

private:
    void updateItem();
    int m_id;
};

#endif // WINDOWPIXMAPITEM_H
