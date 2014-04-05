#include "glacierwindowmodel.h"

GlacierWindowModel::GlacierWindowModel(): WindowModel()
{
}

GlacierWindowModel::~GlacierWindowModel() {

}

bool GlacierWindowModel::approveWindow(LipstickCompositorWindow *window)
{
    return window->isInProcess() == false && window->category() != QLatin1String("overlay") && window->category() != QLatin1String("cover");
}
