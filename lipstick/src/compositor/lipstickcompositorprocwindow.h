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

#ifndef LIPSTICKCOMPOSITORPROCWINDOW_H
#define LIPSTICKCOMPOSITORPROCWINDOW_H

#include "lipstickcompositorwindow.h"

#include <QPointer>

class LipstickCompositorProcWindow : public LipstickCompositorWindow
{
    Q_OBJECT
    Q_PROPERTY(QQuickItem *rootItem READ rootItem NOTIFY rootItemChanged)
public:
    void hide();

    virtual bool isInProcess() const;
    virtual bool isTextureProvider() const { return false; }

    virtual QString title() const;
    void setTitle(const QString &);

    QQuickItem *rootItem();
    void setRootItem(QQuickItem *item);

signals:
    void rootItemChanged();

private:
    friend class LipstickCompositor;
    LipstickCompositorProcWindow(int windowId, const QString &, QQuickItem *parent = 0);

    QString m_title;
    QPointer<QQuickItem> m_rootItem;
};

#endif // LIPSTICKCOMPOSITORPROCWINDOW_H
