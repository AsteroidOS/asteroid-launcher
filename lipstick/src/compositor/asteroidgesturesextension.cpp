/*
 * Copyright (C) 2026 Florent Revest <revestflo@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License version 2.1 as published by the Free Software Foundation.
 */

#include "asteroidgesturesextension.h"

#include <QWaylandCompositor>
#include <QWaylandSurface>
#include <QWaylandView>

#include "lipstickcompositorwindow.h"

AsteroidGesturesManager::AsteroidGesturesManager(QWaylandCompositor *compositor)
    : QWaylandCompositorExtensionTemplate<AsteroidGesturesManager>(compositor)
{
}

void AsteroidGesturesManager::initialize()
{
    QWaylandCompositorExtensionTemplate::initialize();
    auto *compositor = static_cast<QWaylandCompositor *>(extensionContainer());
    init(compositor->display(), 1);
}

void AsteroidGesturesManager::zasteroid_gestures_manager_v1_destroy(Resource *resource)
{
    wl_resource_destroy(resource->handle);
}

void AsteroidGesturesManager::zasteroid_gestures_manager_v1_get_gesture_surface(
    Resource *resource, uint32_t id, ::wl_resource *surface_resource)
{
    auto *surface = QWaylandSurface::fromResource(surface_resource);
    new AsteroidGestureSurface(resource->client(), id, resource->version(), surface);
}

AsteroidGestureSurface::AsteroidGestureSurface(wl_client *client, uint32_t id, int version,
                                               QWaylandSurface *surface)
    : QtWaylandServer::zasteroid_gesture_surface_v1(client, id, version)
    , m_surface(surface)
{
}

AsteroidGestureSurface::~AsteroidGestureSurface() = default;

void AsteroidGestureSurface::zasteroid_gesture_surface_v1_destroy_resource(Resource *)
{
    applyToWindow(false);
    delete this;
}

void AsteroidGestureSurface::zasteroid_gesture_surface_v1_destroy(Resource *resource)
{
    wl_resource_destroy(resource->handle);
}

void AsteroidGestureSurface::zasteroid_gesture_surface_v1_set_overrides_system_gestures(
    Resource *, uint32_t enabled)
{
    applyToWindow(enabled != 0);
}

void AsteroidGestureSurface::applyToWindow(bool enabled)
{
    if (!m_surface)
        return;
    const auto views = m_surface->views();
    for (QWaylandView *view : views) {
        if (auto *window = qobject_cast<LipstickCompositorWindow *>(view->renderObject())) {
            window->setOverridesSystemGestures(enabled);
            return;
        }
    }
}
