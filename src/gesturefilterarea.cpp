/*
 * Copyright (C) 2017 Florent Revest <revestflo@gmail.com>
 * All rights reserved.
 *
 * You may use this file under the terms of BSD license as follows:
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the author nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Touch is handled natively, following the pattern of
 * QQuickFlickable::childMouseEventFilter(): touch events are processed
 * directly in the filter, the exclusive grab is taken by accepting the
 * filtered touch event, and further updates then arrive in touchEvent().
 * The mouse path is kept for pointer devices.
 */

#include "gesturefilterarea.h"

#include <QQuickWindow>
#include <QScreen>

GestureFilterArea::GestureFilterArea(QQuickItem *parent) : QQuickItem(parent)
{
    setFiltersChildMouseEvents(true);
    setAcceptedMouseButtons(Qt::LeftButton);
    setAcceptTouchEvents(true);
    m_toLeftAllowed = true;
    m_toRightAllowed = true;
    m_toBottomAllowed = true;
    m_toTopAllowed = true;
    m_pressed = false;
    m_grabbed = false;

    m_threshold = width()*0.01;
}

void GestureFilterArea::geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    m_threshold = newGeometry.width()*0.01;
    QQuickItem::geometryChange(newGeometry, oldGeometry);
}

/* Shared gesture state machine */

void GestureFilterArea::beginTracking(const QPointF &pos)
{
    m_pressed = true;
    m_grabbed = false;
    m_velocityX = 0;
    m_velocityY = 0;
    m_tracing = true;
    m_horizontal = false;
    m_prevPos = pos;
    m_counter = 0;
}

bool GestureFilterArea::trackMove(const QPointF &pos)
{
    bool wantsGrab = false;
    m_counter++;

    m_velocityX = (m_velocityX*(m_counter-1) + (pos.x()-m_prevPos.x()))/m_counter;
    m_velocityY = (m_velocityY*(m_counter-1) + (pos.y()-m_prevPos.y()))/m_counter;
    if(m_tracing) {
        if (abs(m_velocityX) > abs(m_velocityY)) {
            if(m_velocityX > m_threshold) {
                m_tracing = false;
                if(m_toRightAllowed) {
                    m_horizontal = true;
                    wantsGrab = true;
                }
                else
                    m_pressed = false;
            } else if(m_velocityX < -m_threshold) {
                m_tracing = false;
                if(m_toLeftAllowed) {
                    m_horizontal = true;
                    wantsGrab = true;
                }
                else
                    m_pressed = false;
            }
        } else {
            if(m_velocityY > m_threshold) {
                m_tracing = false;
                if(m_toBottomAllowed) {
                    m_horizontal = false;
                    wantsGrab = true;
                }
                else
                    m_pressed = false;
            } else if(m_velocityY < -m_threshold) {
                m_tracing = false;
                if(m_toTopAllowed) {
                    m_horizontal = false;
                    wantsGrab = true;
                }
                else
                    m_pressed = false;
            }
        }
    } else if(m_pressed && m_grabbed) {
        qreal delta;
        if(m_horizontal)
            delta = pos.x() - m_prevPos.x();
        else
            delta = pos.y() - m_prevPos.y();

        emit swipeMoved(m_horizontal, delta);
    }
    m_prevPos = pos;
    return wantsGrab;
}

void GestureFilterArea::finishTracking()
{
    if (!m_pressed)
        return;
    if (m_grabbed) {
        qreal currVel = m_horizontal ? m_velocityX : m_velocityY;
        emit swipeReleased(m_horizontal, currVel, m_tracing);
    }
    m_pressed = false;
    m_grabbed = false;
    setKeepTouchGrab(false);
    setKeepMouseGrab(false);
}

/* Child event filtering */

bool GestureFilterArea::childMouseEventFilter(QQuickItem *i, QEvent *e)
{
    if (!isVisible() || !isEnabled())
        return QQuickItem::childMouseEventFilter(i, e);

    switch (e->type()) {
    case QEvent::MouseButtonPress:
    case QEvent::MouseMove:
    case QEvent::MouseButtonRelease:
        return filterMouseEvent(i, static_cast<QMouseEvent *>(e));
    case QEvent::TouchBegin:
    case QEvent::TouchUpdate:
    case QEvent::TouchEnd:
        return filterTouchEvent(i, static_cast<QTouchEvent *>(e));
    case QEvent::UngrabMouse:
        if (window() && window()->mouseGrabberItem() && window()->mouseGrabberItem() != this) {
            // The grab has been taken away from a child and given to some other item.
            mouseUngrabEvent();
        }
        break;
    default:
        break;
    }

    return QQuickItem::childMouseEventFilter(i, e);
}

bool GestureFilterArea::filterTouchEvent(QQuickItem *item, QTouchEvent *event)
{
    Q_UNUSED(item)
    if (event->pointCount() != 1)
        return false;

    const QEventPoint &point = event->points().first();
    QPointF localPos = mapFromScene(point.scenePosition());
    if (!contains(localPos))
        return false;

    QQuickItem *grabber = qobject_cast<QQuickItem *>(event->exclusiveGrabber(point));
    if (grabber && grabber != this && (grabber->keepTouchGrab() || grabber->keepMouseGrab()))
        return false;

    switch (point.state()) {
    case QEventPoint::State::Pressed:
        beginTracking(localPos);
        break;
    case QEventPoint::State::Updated:
        if (m_pressed && trackMove(localPos)) {
            // Threshold crossed in an allowed direction: take the swipe.
            // Accepting the filtered event and returning true makes the
            // delivery agent transfer the exclusive grab to us (respecting a
            // child's keepTouchGrab, checked above); subsequent updates then
            // arrive natively in touchEvent().
            m_grabbed = true;
            setKeepTouchGrab(true);
            setKeepMouseGrab(true);
            event->accept();
            return true;
        }
        break;
    case QEventPoint::State::Released:
        // Released before any grab: the child owns this gesture (tap/scroll).
        m_pressed = false;
        break;
    default:
        break;
    }
    return false;
}

bool GestureFilterArea::filterMouseEvent(QQuickItem *item, QMouseEvent *event)
{
    Q_UNUSED(item)
    QPointF localPos = mapFromScene(event->scenePosition());
    if (!contains(localPos))
        return false;

    QQuickWindow *c = window();
    QQuickItem *grabber = c ? c->mouseGrabberItem() : nullptr;
    if (grabber && grabber != this && grabber->keepMouseGrab())
        return false;

    switch (event->type()) {
    case QEvent::MouseButtonPress:
        beginTracking(localPos);
        break;
    case QEvent::MouseMove:
        if (m_pressed && trackMove(localPos)) {
            m_grabbed = true;
            setKeepMouseGrab(true);
            grabMouse();
        }
        break;
    case QEvent::MouseButtonRelease:
        m_pressed = false;
        break;
    default:
        break;
    }
    return false;
}

/* Direct delivery: GestureFilterArea itself is the target (nothing pressable
 * under the finger) or has become the exclusive grabber. */

void GestureFilterArea::touchEvent(QTouchEvent *event)
{
    if (!isEnabled() || event->pointCount() != 1) {
        QQuickItem::touchEvent(event);
        return;
    }
    const QEventPoint &point = event->points().first();
    QPointF localPos = mapFromScene(point.scenePosition());

    switch (point.state()) {
    case QEventPoint::State::Pressed:
        beginTracking(localPos);
        // Accepting the press makes us the exclusive grabber of the point, so
        // updates keep coming even though nothing else is under the finger.
        // The gesture counts as grabbed from the start here — there is no
        // child to hand a tap over to.
        m_grabbed = true;
        event->accept();
        break;
    case QEventPoint::State::Updated:
        if (m_pressed)
            trackMove(localPos);
        event->accept();
        break;
    case QEventPoint::State::Released:
        finishTracking();
        event->accept();
        break;
    default:
        QQuickItem::touchEvent(event);
        break;
    }
}

void GestureFilterArea::mousePressEvent(QMouseEvent *event) {
    if (!isEnabled() || !(event->button() & acceptedMouseButtons())) {
        QQuickItem::mousePressEvent(event);
    } else {
        beginTracking(event->position());
        m_grabbed = true;
        event->accept();
    }
}

void GestureFilterArea::mouseMoveEvent(QMouseEvent *event) {
    if (!isEnabled() || !m_pressed) {
        QQuickItem::mouseMoveEvent(event);
        return;
    }
    trackMove(event->position());
}

void GestureFilterArea::mouseReleaseEvent(QMouseEvent *event) {
    if (!isEnabled() || !m_pressed)
        QQuickItem::mouseReleaseEvent(event);
    else
        finishTracking();
}

void GestureFilterArea::mouseUngrabEvent() {
    m_pressed = false;
    m_grabbed = false;
    setKeepMouseGrab(false);
}

void GestureFilterArea::touchUngrabEvent() {
    m_pressed = false;
    m_grabbed = false;
    setKeepTouchGrab(false);
}
