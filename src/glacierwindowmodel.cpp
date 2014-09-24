#include "glacierwindowmodel.h"

GlacierWindowModel::GlacierWindowModel(): WindowModel()
{
}

int GlacierWindowModel::getWindowIdForTitle(QString title)
{
    return m_titles.value(title,0);
}



bool GlacierWindowModel::approveWindow(LipstickCompositorWindow *window)
{
    bool accepted = window->isInProcess() == false && window->category() != QLatin1String("overlay") && window->category() != QLatin1String("cover");
    if (accepted) {
        m_titles.insert(window->title(), window->windowId());
    }
    return accepted;
}

void GlacierWindowModel::removeWindowForTitle(QString title)
{
    qDebug() << "Removing window: " + title;
    m_titles.remove(title);
}

#include "moc_glacierwindowmodel.cpp"
