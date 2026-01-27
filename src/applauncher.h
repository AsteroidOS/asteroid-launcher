#ifndef APPLAUNCHER_H
#define APPLAUNCHER_H

#include <QObject>
#include <QProcess>

class AppLauncher : public QObject
{
    Q_OBJECT
public:
    explicit AppLauncher(QObject *parent = nullptr);

    Q_INVOKABLE bool launchApp(const QString &appName);

    Q_INVOKABLE bool launchDesktopFile(const QString &desktopFile);
};

#endif // APPLAUNCHER_H
