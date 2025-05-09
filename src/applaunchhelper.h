#ifndef APPLAUNCHHELPER_H
#define APPLAUNCHHELPER_H

#include <QObject>
#include <QProcess>

class AppLaunchHelper : public QObject
{
    Q_OBJECT
public:
    explicit AppLaunchHelper(QObject *parent = nullptr);

    Q_INVOKABLE bool launchApp(const QString &appName);
};

#endif // APPLAUNCHHELPER_H
