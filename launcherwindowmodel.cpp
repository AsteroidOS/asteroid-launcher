#include "launcherwindowmodel.h"

LauncherWindowModel::LauncherWindowModel(): WindowModel()
{
}

int LauncherWindowModel::getWindowIdForTitle(QString title)
{
    return m_titles.value(title,0);
}

bool LauncherWindowModel::approveWindow(LipstickCompositorWindow *window)
{
    bool accepted = window->isInProcess() == false && window->category() != QLatin1String("overlay") && window->category() != QLatin1String("cover");
    if (accepted) {
        m_titles.insert(window->title(), window->windowId());
    }
    return accepted;
}

void LauncherWindowModel::removeWindowForTitle(QString title)
{
    qDebug() << "Removing window: " + title;
    m_titles.remove(title);
}
