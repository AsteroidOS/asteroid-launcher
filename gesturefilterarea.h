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

#ifndef GESTUREFILTERAREA_H
#define GESTUREFILTERAREA_H

#include <QObject>
#include <QQuickItem>

class GestureFilterArea : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(bool toRightAllowed WRITE setToRightAllowed READ toRightAllowed NOTIFY toRightAllowedChanged)
    Q_PROPERTY(bool toLeftAllowed WRITE setToLeftAllowed READ toLeftAllowed NOTIFY toLeftAllowedChanged)
    Q_PROPERTY(bool toBottomAllowed WRITE setToBottomAllowed READ toBottomAllowed NOTIFY toBottomAllowedChanged)
    Q_PROPERTY(bool toTopAllowed WRITE setToTopAllowed READ toTopAllowed NOTIFY toTopAllowedChanged)

public:
    GestureFilterArea(QQuickItem *parent = 0);
    bool toRightAllowed()  { return m_toRightAllowed;  }
    bool toLeftAllowed()   { return m_toLeftAllowed;   }
    bool toBottomAllowed() { return m_toBottomAllowed; }
    bool toTopAllowed()    { return m_toTopAllowed;    }

    void setToRightAllowed(const bool allowed) {
        if (m_toRightAllowed != allowed) {
            m_toRightAllowed = allowed;
            emit toRightAllowedChanged();
        }
    }
    void setToLeftAllowed(const bool allowed) {
        if (m_toLeftAllowed != allowed) {
            m_toLeftAllowed = allowed;
            emit toLeftAllowedChanged();
        }
    }
    void setToBottomAllowed(const bool allowed) {
        if (m_toBottomAllowed != allowed) {
            m_toBottomAllowed = allowed;
            emit toBottomAllowedChanged();
        }
    }
    void setToTopAllowed(const bool allowed) {
        if (m_toTopAllowed != allowed) {
            m_toTopAllowed = allowed;
            emit toTopAllowedChanged();
        }
    }

signals:
    void swipeMoved(bool horizontal, qreal delta);
    void swipeReleased(bool horizontal, qreal velocity);

    void toRightAllowedChanged();
    void toLeftAllowedChanged();
    void toTopAllowedChanged();
    void toBottomAllowedChanged();

private:
    bool m_toRightAllowed, m_toLeftAllowed, m_toBottomAllowed, m_toTopAllowed;

    bool m_horizontal, m_pressed, m_tracing;
    unsigned int m_counter;
    QPointF m_prevPos;
    qreal m_velocityX, m_velocityY;

protected:
    virtual bool childMouseEventFilter(QQuickItem *, QEvent *);
    virtual void mousePressEvent(QMouseEvent *event);
    virtual void mouseMoveEvent(QMouseEvent *event);
    virtual void mouseReleaseEvent(QMouseEvent *event);
    virtual void mouseUngrabEvent();
    bool filterMouseEvent(QQuickItem *item, QMouseEvent *event);
};

#endif // GESTUREFILTERAREA_H
