cmake_minimum_required(VERSION 3.6.0)

project(asteroid-launcher
	VERSION 0.0.1
	DESCRIPTION "AsteroidOS launcher and Wayland compositor based on Qt5, QML and QtWayland via Lipstick")

find_package(ECM REQUIRED NO_MODULE)
find_package(AsteroidApp REQUIRED)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ASTEROID_MODULE_PATH})

include(FeatureSummary)
include(GNUInstallDirs)
include(ECMQMLModules)
include(AsteroidCMakeSettings)
include(AsteroidTranslations)

find_package(Qt5 ${QT_MIN_VERSION} COMPONENTS Quick WaylandCompositor DBus REQUIRED)
find_package(Mlite5 REQUIRED)
find_package(Lipstick REQUIRED)
find_package(Timed REQUIRED)

ecm_find_qmlmodule(org.nemomobile.calendar 1.0)
ecm_find_qmlmodule(org.nemomobile.systemsettings 1.0)
ecm_find_qmlmodule(Nemo.Mce 1.0)
ecm_find_qmlmodule(Nemo.DBus 2.0)
ecm_find_qmlmodule(Nemo.Configuration 1.0)
ecm_find_qmlmodule(Nemo.Time 1.0)
ecm_find_qmlmodule(Nemo.Ngf 1.0)

add_subdirectory(src)

build_translations(i18n)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
