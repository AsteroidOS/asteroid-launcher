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

#include <QCoreApplication>
#include <QWaylandCompositor>
#include <QWaylandSeat>
#include <QTimer>
#include <QEvent>
#include <sys/types.h>
#include <signal.h>
#include "lipstickcompositor.h"
#include "lipstickcompositorwindow.h"


LipstickCompositorWindow::LipstickCompositorWindow(int windowId, const QString &category,
                                                   QWaylandSurface *surface, QQuickItem *parent)
: QWaylandQuickItem(), m_windowId(windowId), m_category(category),
  m_delayRemove(false), m_windowClosed(false), m_removePosted(false),
  m_interceptingTouch(false), m_mapped(false), m_processId(0),
  m_focusOnTouch(false), m_overridesSystemGestures(false)
{
    setFlags(QQuickItem::ItemIsFocusScope | flags());

    // Handle ungrab situations
    connect(this, SIGNAL(visibleChanged()), SLOT(handleTouchCancel()));
    connect(this, SIGNAL(enabledChanged()), SLOT(handleTouchCancel()));
    connect(this, SIGNAL(touchEventsEnabledChanged()), SLOT(handleTouchCancel()));

    if(surface) {
        connect(surface, SIGNAL(surfaceDestroyed()), this, SLOT(deleteLater()));
        connect(surface, &QWaylandSurface::configure, this, &LipstickCompositorWindow::committed);

        m_processId = surface->client()->processId();
        setSurface(surface);
    }
}

LipstickCompositorWindow::~LipstickCompositorWindow()
{
    // We don't want tryRemove() posting an event anymore, we're dying anyway
    m_removePosted = true;
    LipstickCompositor::instance()->windowDestroyed(this);
}

QVariant LipstickCompositorWindow::userData() const
{
    return m_data;
}

void LipstickCompositorWindow::setUserData(QVariant data)
{
    if (m_data == data)
        return;

    m_data = data;
    emit userDataChanged();
}

int LipstickCompositorWindow::windowId() const
{
    return m_windowId;
}

qint64 LipstickCompositorWindow::processId() const
{
    return m_processId;
}

bool LipstickCompositorWindow::delayRemove() const
{
    return m_delayRemove;
}

void LipstickCompositorWindow::setDelayRemove(bool delay)
{
    if (delay == m_delayRemove)
        return;

    emit delayRemoveChanged();

    tryRemove();
}

QString LipstickCompositorWindow::category() const
{
    return m_category;
}


qint16 LipstickCompositorWindow::windowFlags()
{
    return 0;
}

QVariantMap LipstickCompositorWindow::windowProperties()
{
    return QVariantMap();
}

void LipstickCompositorWindow::setTitle(QString title)
{
    m_title = title;
}

QString LipstickCompositorWindow::title() const
{
    return m_title;
}

void LipstickCompositorWindow::imageAddref(QQuickItem *item)
{
    Q_ASSERT(!m_refs.contains(item));
    m_refs << item;
}

void LipstickCompositorWindow::imageRelease(QQuickItem *item)
{
    Q_ASSERT(m_refs.contains(item));
    m_refs.remove(m_refs.indexOf(item));
    Q_ASSERT(!m_refs.contains(item));

    tryRemove();
}

bool LipstickCompositorWindow::canRemove() const
{
    return m_windowClosed && !m_delayRemove && m_refs.size() == 0;
}

void LipstickCompositorWindow::tryRemove()
{
    if (canRemove() && !m_removePosted) {
        m_removePosted = true;
        QCoreApplication::postEvent(this, new QEvent(QEvent::User));
    }
}

bool LipstickCompositorWindow::eventFilter(QObject *obj, QEvent *event)
{
    if (obj == window() && m_interceptingTouch) {
        switch (event->type()) {
        case QEvent::TouchUpdate: {
            QTouchEvent *te = static_cast<QTouchEvent *>(event);
            // If we get press/release, don't intercept the event, but send it through QQuickWindow.
            // These are sent through to QQuickWindow so that the integrity of the touch
            // handling is maintained.
            if (te->touchPointStates() & (Qt::TouchPointPressed | Qt::TouchPointReleased))
                return false;
            handleTouchEvent(static_cast<QTouchEvent *>(event));
            return true;
        }
        case QEvent::TouchEnd: // Intentional fall through...
        case QEvent::TouchCancel:
            obj->removeEventFilter(this);
            m_interceptingTouch = false;
        default:
            break;
        }
        return false;
    }
    if (event->type() == 6 || event->type() == 7) {
        QKeyEvent *ke = static_cast<QKeyEvent *>(event);
        QWaylandSurface *m_surface = surface();
        if (m_surface) {
            QWaylandSeat *inputDevice = m_surface->compositor()->seatFor(ke);
            if (event->type() == 6) //KeyPress
                inputDevice->setKeyboardFocus(m_surface);
            inputDevice->sendFullKeyEvent(ke);
            if (event->type() == 7) //KeyRelease
                qApp->removeEventFilter(this);
            return true;
        }
    }
    return false;
}

bool LipstickCompositorWindow::isInProcess() const
{
    return false;
}

void LipstickCompositorWindow::itemChange(ItemChange change, const ItemChangeData &data)
{
    if (change == ItemSceneChange) {
        handleTouchCancel();
    }
    QWaylandQuickItem::itemChange(change, data);
}

bool LipstickCompositorWindow::event(QEvent *e)
{
    bool rv = QWaylandQuickItem::event(e);
    if (e->type() == QEvent::User) {
        m_removePosted = false;
        if (canRemove()) delete this;
    }
    return rv;
}

void LipstickCompositorWindow::mousePressEvent(QMouseEvent *event)
{
    QWaylandSurface *m_surface = surface();
    if (m_surface && m_surface->inputRegionContains(event->pos()) && event->source() != Qt::MouseEventSynthesizedByQt) {
        QWaylandSeat *inputDevice = m_surface->compositor()->seatFor(event);
        QWaylandView *v = view();
        if (inputDevice->mouseFocus() != v) {
            inputDevice->setMouseFocus(v);
            if (m_focusOnTouch && inputDevice->keyboardFocus() != m_surface) {
                takeFocus();
            }
        }
        inputDevice->sendMousePressEvent(event->button());
    } else {
        event->ignore();
    }
}

void LipstickCompositorWindow::mouseMoveEvent(QMouseEvent *event)
{
    QWaylandSurface *m_surface = surface();
    if (m_surface && event->source() != Qt::MouseEventSynthesizedByQt) {
        QWaylandView *v = view();
        QWaylandSeat *inputDevice = m_surface->compositor()->seatFor(event);
        inputDevice->sendMouseMoveEvent(v, event->localPos(), event->globalPos());
    } else {
        event->ignore();
    }
}

void LipstickCompositorWindow::mouseReleaseEvent(QMouseEvent *event)
{
    QWaylandSurface *m_surface = surface();
    if (m_surface && event->source() != Qt::MouseEventSynthesizedByQt) {
        QWaylandSeat *inputDevice = m_surface->compositor()->seatFor(event);
        inputDevice->sendMouseReleaseEvent(event->button());
    } else {
        event->ignore();
    }
}

void LipstickCompositorWindow::wheelEvent(QWheelEvent *event)
{
    QWaylandSurface *m_surface = surface();
    if (m_surface) {
        QWaylandSeat *inputDevice = m_surface->compositor()->seatFor(event);
        QWaylandView *v = view();
        // Hover mouse above window to allow wheel events to arrive.
        if (v != inputDevice->mouseFocus()) {
            QPointF pos(0, 0);
            inputDevice->sendMouseMoveEvent(v, pos, pos);
        }
        QPoint angle = event->angleDelta();
        inputDevice->sendMouseWheelEvent(Qt::Vertical, angle.y());
    } else {
        event->ignore();
    }
}

void LipstickCompositorWindow::touchEvent(QTouchEvent *event)
{
    if (touchEventsEnabled() && surface()) {
        handleTouchEvent(event);

        static bool lipstick_touch_interception = qEnvironmentVariableIsEmpty("LIPSTICK_NO_TOUCH_INTERCEPTION");
        if (lipstick_touch_interception && event->type() == QEvent::TouchBegin) {
            // On TouchBegin, start intercepting
            if (event->isAccepted() && !m_interceptingTouch) {
                m_interceptingTouch = true;
                window()->installEventFilter(this);
            }
        }
    } else {
        event->ignore();
    }
}

void LipstickCompositorWindow::handleTouchEvent(QTouchEvent *event)
{
    QList<QTouchEvent::TouchPoint> points = event->touchPoints();

    QWaylandSurface *m_surface = surface();
    if (!m_surface) {
        event->ignore();
        return;
    }

    if (event->touchPointStates() & Qt::TouchPointPressed) {
        foreach (const QTouchEvent::TouchPoint &p, points) {
            if (!m_surface->inputRegionContains(p.pos().toPoint())) {
                event->ignore();
                return;
            }
        }
    }

    QWaylandSeat *inputDevice = m_surface->compositor()->seatFor(event);
    event->accept();

    QWaylandView *vview = view();
    if (vview && (!vview->surface() || vview->surface()->isCursorSurface()))
        vview = Q_NULLPTR;
    inputDevice->setMouseFocus(vview);

    QWaylandView *v = view();
    if (inputDevice->mouseFocus() != v) {
        QPoint pointPos;
        if (!points.isEmpty())
            pointPos = points.at(0).pos().toPoint();
        inputDevice->setMouseFocus(v);

        if (m_focusOnTouch && inputDevice->keyboardFocus() != m_surface) {
            takeFocus();
        }
    }
    inputDevice->sendFullTouchEvent(surface(), event);
}

void LipstickCompositorWindow::handleTouchCancel()
{
    QWaylandSurface *m_surface = surface();
    if (!m_surface)
        return;
    QWaylandSeat *inputDevice = m_surface->compositor()->defaultSeat();
    QWaylandView *v = view();
    if (inputDevice->mouseFocus() == v &&
            (!isVisible() || !isEnabled() || !touchEventsEnabled())) {
        inputDevice->sendTouchCancelEvent(surface()->client());
        inputDevice->setMouseFocus(0);
    }
    if (QWindow *w = window())
        w->removeEventFilter(this);
    m_interceptingTouch = false;
}

void LipstickCompositorWindow::terminateProcess(int killTimeout)
{
    pid_t pid = processId();
    if (pid > 0) {
        kill(pid, SIGTERM);
        QTimer::singleShot(killTimeout, this, SLOT(killProcess()));
    }
}

void LipstickCompositorWindow::killProcess()
{
    pid_t pid = processId();
    if (pid > 0) {
        kill(pid, SIGKILL);
    }
}

bool LipstickCompositorWindow::focusOnTouch() const
{
    return m_focusOnTouch;
}

void LipstickCompositorWindow::setFocusOnTouch(bool focusOnTouch)
{
    if (m_focusOnTouch == focusOnTouch)
        return;

    m_focusOnTouch = focusOnTouch;
    emit focusOnTouchChanged();
}

bool LipstickCompositorWindow::overridesSystemGestures() const
{
    return m_overridesSystemGestures;
}

void LipstickCompositorWindow::setOverridesSystemGestures(bool enabled)
{
    if (m_overridesSystemGestures == enabled)
        return;

    m_overridesSystemGestures = enabled;
    emit overridesSystemGesturesChanged();
}

