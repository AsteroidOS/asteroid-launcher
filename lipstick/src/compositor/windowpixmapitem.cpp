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

#include "windowpixmapitem.h"
#include "lipstickcompositor.h"
#include "lipstickcompositorwindow.h"
#include <QDebug>

WindowPixmapItem::WindowPixmapItem() : m_id(0)
{
#if QT_VERSION < QT_VERSION_CHECK(5, 15, 0)
    setSizeFollowsSurface(false);
#endif
    setEnabled(false);
}

WindowPixmapItem::~WindowPixmapItem()
{
    setWindowId(0);
}

int WindowPixmapItem::windowId() const
{
    return m_id;
}

void WindowPixmapItem::setWindowId(int id)
{
    if (m_id == id)
        return;
    m_id = id;
    LipstickCompositor *c = LipstickCompositor::instance();
    if (c && m_id) {
        LipstickCompositorWindow *w = static_cast<LipstickCompositorWindow *>(c->windowForId(m_id));

        if (w)
            setSurface(w->surface());
    }
    emit windowIdChanged();
}

