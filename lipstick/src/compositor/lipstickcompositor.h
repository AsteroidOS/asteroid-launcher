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

#ifndef LIPSTICKCOMPOSITOR_H
#define LIPSTICKCOMPOSITOR_H

#include <QQuickWindow>
#include <QWaylandSurface>
#include "lipstickglobal.h"
#include <QWaylandQuickCompositor>
#include <QWaylandQuickOutput>
#include <QWaylandXdgShell>
#include <QWaylandQtWindowManager>
#include <QQmlComponent>
#include <QWaylandClient>
#include <QPointer>
#include <QTimer>
#include <MDConfItem>
#include <qmdisplaystate.h>

#include <timed-qt6/interface>
#include <timed-qt6/exception>
#include <timed-qt6/event-declarations.h>

class LipstickCompositorWindow;
class LipstickCompositorProcWindow;
class QOrientationSensor;
class LipstickRecorderManager;
class AsteroidGesturesManager;

class LIPSTICK_EXPORT LipstickCompositor : public QWaylandQuickCompositor
{
    Q_OBJECT

    Q_PROPERTY(int windowCount READ windowCount NOTIFY windowCountChanged)
    Q_PROPERTY(int ghostWindowCount READ ghostWindowCount NOTIFY ghostWindowCountChanged)
    Q_PROPERTY(bool homeActive READ homeActive WRITE setHomeActive NOTIFY homeActiveChanged)
    Q_PROPERTY(bool debug READ debug CONSTANT)
    Q_PROPERTY(QWaylandSurface* fullscreenSurface READ fullscreenSurface WRITE setFullscreenSurface NOTIFY fullscreenSurfaceChanged)
    Q_PROPERTY(bool directRenderingActive READ directRenderingActive NOTIFY directRenderingActiveChanged)
    Q_PROPERTY(int topmostWindowId READ topmostWindowId WRITE setTopmostWindowId NOTIFY topmostWindowIdChanged)
    Q_PROPERTY(Qt::ScreenOrientation topmostWindowOrientation READ topmostWindowOrientation WRITE setTopmostWindowOrientation NOTIFY topmostWindowOrientationChanged)
    Q_PROPERTY(Qt::ScreenOrientation screenOrientation READ screenOrientation WRITE setScreenOrientation NOTIFY screenOrientationChanged)
    Q_PROPERTY(Qt::ScreenOrientation sensorOrientation READ sensorOrientation NOTIFY sensorOrientationChanged)
    Q_PROPERTY(QObject* clipboard READ clipboard CONSTANT)
    Q_PROPERTY(QVariant orientationLock READ orientationLock NOTIFY orientationLockChanged)
    Q_PROPERTY(bool displayDimmed READ displayDimmed NOTIFY displayDimmedChanged)
    Q_PROPERTY(bool completed READ completed NOTIFY completedChanged)
    Q_PROPERTY(QQuickWindow *quickWindow READ quickWindow CONSTANT)
    Q_PROPERTY(bool ambientSupported READ ambientSupported CONSTANT)
    Q_PROPERTY(bool ambientEnabled READ ambientEnabled WRITE setAmbientEnabled NOTIFY ambientEnabledChanged)
    Q_PROPERTY(bool displayAmbient READ displayAmbient NOTIFY displayAmbientChanged)

public:
    LipstickCompositor();
    ~LipstickCompositor();

    static LipstickCompositor *instance();

    bool openUrl(QWaylandClient *client, const QUrl &url);
    void retainedSelectionReceived(QMimeData *mimeData) Q_DECL_OVERRIDE;

    int windowCount() const;
    int ghostWindowCount() const;

    bool homeActive() const;
    void setHomeActive(bool);

    QWaylandSurface *fullscreenSurface() const { return m_fullscreenSurface; }
    void setFullscreenSurface(QWaylandSurface *surface);
    bool directRenderingActive() const { return m_directRenderingActive; }

    int topmostWindowId() const { return m_topmostWindowId; }
    void setTopmostWindowId(int id);
    int privateTopmostWindowProcessId() const { return m_topmostWindowProcessId; }

    Qt::ScreenOrientation topmostWindowOrientation() const { return m_topmostWindowOrientation; }
    void setTopmostWindowOrientation(Qt::ScreenOrientation topmostWindowOrientation);

    Qt::ScreenOrientation screenOrientation() const { return m_screenOrientation; }
    void setScreenOrientation(Qt::ScreenOrientation screenOrientation);

    Qt::ScreenOrientation sensorOrientation() const { return m_sensorOrientation; }

    QVariant orientationLock() const { return m_orientationLock->value("dynamic"); }

    bool displayDimmed() const { return m_currentDisplayState == MeeGo::QmDisplayState::Dimmed; }

    QObject *clipboard() const;

    bool debug() const;

    Q_INVOKABLE QObject *windowForId(int) const;
    Q_INVOKABLE void closeClientForWindowId(int);
    Q_INVOKABLE void clearKeyboardFocus();
    Q_INVOKABLE void setDisplayOff();
    Q_INVOKABLE QVariant settingsValue(const QString &key, const QVariant &defaultValue = QVariant()) const
        { return (key == "orientationLock") ? m_orientationLock->value(defaultValue) : MDConfItem("/lipstick/" + key).value(defaultValue); }

    LipstickCompositorProcWindow *mapProcWindow(const QString &title, const QString &category, const QRect &);
    LipstickCompositorProcWindow *mapProcWindow(const QString &title, const QString &category, const QRect &, QQuickItem *rootItem);

    QWaylandSurface *surfaceForId(int) const;

    bool completed();

    bool ambientSupported() const;
    void setAmbientEnabled(bool enabled);
    bool ambientEnabled() const { return m_ambientModeEnabled; }
    Q_INVOKABLE void setAmbientUpdatesEnabled(bool enabled);

    bool displayAmbient() const { return (m_currentDisplayState == MeeGo::QmDisplayState::Off) && ambientEnabled(); }
    Q_INVOKABLE void setUpdatesEnabled(bool enabled, bool inAmbientMode = false);
    LipstickCompositorWindow *createView(QWaylandSurface *surf);

    QQuickWindow *quickWindow() { return m_window; }

protected:
    void timerEvent(QTimerEvent *e) Q_DECL_OVERRIDE;

signals:
    void windowAdded(QObject *window);
    void windowRemoved(QObject *window);
    void windowRaised(QObject *window);
    void windowLowered(QObject *window);
    void windowHidden(QObject *window);

    void windowCountChanged();
    void ghostWindowCountChanged();

    void availableWinIdsChanged();

    void homeActiveChanged();
    void fullscreenSurfaceChanged();
    void directRenderingActiveChanged();
    void topmostWindowIdChanged();
    void privateTopmostWindowProcessIdChanged(int pid);
    void topmostWindowOrientationChanged();
    void screenOrientationChanged();
    void sensorOrientationChanged();
    void orientationLockChanged();
    void displayDimmedChanged();

    void displayAmbientEntered();
    void displayAmbientLeft();
    // Display entered/left ambient mode.
    void displayAmbientChanged();
    // Update the screen in ambient mode.
    void displayAmbientUpdate();

    void displayOn();
    void displayOff();
    void displayAboutToBeOn();
    void displayAboutToBeOff();

    void ambientEnabledChanged();

    void completedChanged();


private slots:
    void onHasContentChanged();
    void surfaceTitleChanged();
    void surfaceSetFullScreen(QWaylandOutput *output);
    void surfaceDamaged(const QRegion &);
    void windowSwapped();
    void windowDestroyed();
    void reactOnDisplayStateChanges(MeeGo::QmDisplayState::DisplayState state);
    void homeApplicationAboutToDestroy();
    void setScreenOrientationFromSensor();
    void clipboardDataChanged();
    void onVisibleChanged(bool visible);
    void onSurfaceDying();
    void initialize();

    void onToplevelCreated(QWaylandXdgToplevel * topLevel, QWaylandXdgSurface * shellSurface);

private:
    friend class LipstickCompositorWindow;
    friend class LipstickCompositorProcWindow;
    friend class NotificationPreviewPresenter;
    friend class NotificationFeedbackPlayer;

    void surfaceMapped(QWaylandSurface *surface);
    void surfaceUnmapped(QWaylandSurface *surface);
    void surfaceUnmapped(LipstickCompositorWindow *item);

    void windowAdded(int);
    void windowRemoved(int);
    void windowDestroyed(LipstickCompositorWindow *item);
    void surfaceCommitted();
    void onSurfaceCreated(QWaylandSurface *surface);

    QQmlComponent *shaderEffectComponent();

    void scheduleAmbientUpdate();

    static LipstickCompositor *m_instance;

    int m_totalWindowCount;
    QHash<int, LipstickCompositorWindow *> m_mappedSurfaces;
    QHash<int, LipstickCompositorWindow *> m_windows;

    int m_nextWindowId;

    bool m_homeActive;

    QQmlComponent *m_shaderEffect;
    QWaylandSurface *m_fullscreenSurface;
    bool m_directRenderingActive;
    int m_topmostWindowId;
    int m_topmostWindowProcessId;
    Qt::ScreenOrientation m_topmostWindowOrientation;
    Qt::ScreenOrientation m_screenOrientation;
    Qt::ScreenOrientation m_sensorOrientation;
    MeeGo::QmDisplayState *m_displayState;
    QOrientationSensor* m_orientationSensor;
    QPointer<QMimeData> m_retainedSelection;
    MDConfItem *m_orientationLock;
    MeeGo::QmDisplayState::DisplayState m_currentDisplayState;
    bool m_updatesEnabled;
    bool m_completed;
    int m_onUpdatesDisabledUnfocusedWindowId;
    bool m_fakeRepaintTriggered;
    QQuickWindow *m_window;
    QWaylandOutput *m_output;
    QWaylandXdgShell *m_xdgShell;
    QWaylandQtWindowManager *m_wm;
    AsteroidGesturesManager *m_gesturesManager;

    Maemo::Timed::Interface *m_timedDbus;
    bool m_ambientModeEnabled;
};

#endif // LIPSTICKCOMPOSITOR_H
