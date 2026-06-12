/*
 * Copyright (C) 2026 Florent Revest <revestflo@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License version 2.1 as published by the Free Software Foundation.
 */

#ifndef ASTEROIDGESTURESEXTENSION_H
#define ASTEROIDGESTURESEXTENSION_H

#include <QWaylandCompositorExtensionTemplate>
#include "qwayland-server-asteroid-gestures-unstable-v1.h"

class QWaylandSurface;
class LipstickCompositorWindow;

class AsteroidGesturesManager
    : public QWaylandCompositorExtensionTemplate<AsteroidGesturesManager>,
      public QtWaylandServer::zasteroid_gestures_manager_v1
{
    Q_OBJECT
public:
    explicit AsteroidGesturesManager(QWaylandCompositor *compositor);

    void initialize() override;

protected:
    void zasteroid_gestures_manager_v1_destroy(Resource *resource) override;
    void zasteroid_gestures_manager_v1_get_gesture_surface(
        Resource *resource, uint32_t id, ::wl_resource *surface_resource) override;
};

class AsteroidGestureSurface : public QtWaylandServer::zasteroid_gesture_surface_v1
{
public:
    AsteroidGestureSurface(wl_client *client, uint32_t id, int version,
                           QWaylandSurface *surface);
    ~AsteroidGestureSurface() override;

protected:
    void zasteroid_gesture_surface_v1_destroy_resource(Resource *resource) override;
    void zasteroid_gesture_surface_v1_destroy(Resource *resource) override;
    void zasteroid_gesture_surface_v1_set_overrides_system_gestures(
        Resource *resource, uint32_t enabled) override;

private:
    void applyToWindow(bool enabled);

    QPointer<QWaylandSurface> m_surface;
};

#endif // ASTEROIDGESTURESEXTENSION_H
