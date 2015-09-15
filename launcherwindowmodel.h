#ifndef LAUNCHERWINDOWMODEL_H
#define LAUNCHERWINDOWMODEL_H

#include <QDebug>

#include <lipstickcompositorwindow.h>
#include <windowmodel.h>

class LipstickCompositorWindow;
class QWaylandSurfaceItem;

class Q_DECL_EXPORT LauncherWindowModel : public WindowModel
{
    Q_OBJECT
public:
    explicit LauncherWindowModel();
    bool approveWindow(LipstickCompositorWindow *window);
    Q_INVOKABLE int getWindowIdForTitle(QString title);
    Q_INVOKABLE void removeWindowForTitle(QString title);

private:
    QHash<QString, int> m_titles;
};

#endif // WINDOWMODEL_H
