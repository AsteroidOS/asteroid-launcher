#include "applaunchhelper.h"

AppLaunchHelper::AppLaunchHelper(QObject *parent) : QObject(parent)
{
}

bool AppLaunchHelper::launchApp(const QString &appName)
{
    return QProcess::startDetached(appName);
}
