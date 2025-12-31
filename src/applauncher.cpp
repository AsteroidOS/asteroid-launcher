#include "applauncher.h"

AppLauncher::AppLauncher(QObject *parent) : QObject(parent)
{
}

bool AppLauncher::launchApp(const QString &appName)
{
    return QProcess::startDetached(appName);
}

bool AppLauncher::launchDesktopFile(const QString &desktopFile) {
    QString appName = desktopFile;
    if (appName.endsWith(".desktop")) {
        appName.chop(strlen(".desktop"));
    }
    return launchApp(appName);
}
