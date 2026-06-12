TEMPLATE = subdirs
SUBDIRS += src plugin tools

plugin.depends = src
tools.depends = src
tests.depends = src

QMAKE_CLEAN += \
    build-stamp \
    configure-stamp \
    artifacts/*.deb \
    *.log.xml \
    *.log

QMAKE_DISTCLEAN += \
    build-stamp \
    configure-stamp \
    *.log.xml \
    *.log

TRANSLATIONS = $$files(i18n/$$TARGET.*.ts)
