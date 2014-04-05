#ifndef GLACIERWINDOWMODEL_H
#define GLACIERWINDOWMODEL_H
#include <windowmodel.h>
#include <lipstickcompositorwindow.h>
#include <QDebug>
class LipstickCompositorWindow;
class QWaylandSurfaceItem;


class GlacierWindowModel : public WindowModel
{
public:
    explicit GlacierWindowModel();
    ~GlacierWindowModel();
    bool approveWindow(LipstickCompositorWindow *window);
};

#endif // GLACIERWINDOWMODEL_H
