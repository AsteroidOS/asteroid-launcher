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

#include "lipstickcompositor.h"
#include "lipstickcompositorwindow.h"
#include "lipstickcompositorprocwindow.h"

LipstickCompositorProcWindow *LipstickCompositor::mapProcWindow(const QString &title, const QString &category,
                                                                const QRect &g)
{
    return mapProcWindow(title, category, g, 0);
}

LipstickCompositorProcWindow *LipstickCompositor::mapProcWindow(const QString &title, const QString &category,
                                                                const QRect &g, QQuickItem *rootItem)
{
    int id = m_nextWindowId++;

    LipstickCompositorProcWindow *item = new LipstickCompositorProcWindow(id, category, m_window->contentItem());
    item->setSize(g.size());
    item->setTitle(title);
    item->setRootItem(rootItem);
    QObject::connect(item, SIGNAL(destroyed(QObject*)), this, SLOT(windowDestroyed()));
    m_totalWindowCount++;
    m_mappedSurfaces.insert(id, item);
    m_windows.insert(id, item);

    item->setPosition(g.topLeft());
    item->setTouchEventsEnabled(true);

    emit windowCountChanged();
    emit windowAdded(item);

    windowAdded(id);

    emit availableWinIdsChanged();

    return item;
}

LipstickCompositorProcWindow::LipstickCompositorProcWindow(int windowId, const QString &c, QQuickItem *parent)
: LipstickCompositorWindow(windowId, c, 0, parent)
{
}

/*
    Ownership of the window transfers to the compositor, and it might be destroyed at any time.
*/
void LipstickCompositorProcWindow::hide()
{
    LipstickCompositor *c = LipstickCompositor::instance();
    c->surfaceUnmapped(this);
}

bool LipstickCompositorProcWindow::isInProcess() const
{
    return true;
}

QString LipstickCompositorProcWindow::title() const
{
    return m_title;
}

void LipstickCompositorProcWindow::setTitle(const QString &t)
{
    if (t == m_title)
        return;

    m_title = t;
    titleChanged();
}

QQuickItem *LipstickCompositorProcWindow::rootItem()
{
    return m_rootItem.data();
}

void LipstickCompositorProcWindow::setRootItem(QQuickItem *item)
{
    if (m_rootItem != item) {
        m_rootItem = item;
        emit rootItemChanged();
    }
}
