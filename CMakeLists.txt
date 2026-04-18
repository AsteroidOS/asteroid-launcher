cmake_minimum_required(VERSION 3.6.0)

project(asteroid-launcher
	VERSION 2.1
	DESCRIPTION "AsteroidOS launcher and Wayland compositor based on Qt6, QML and QtWayland via Lipstick"
)

find_package(ECM REQUIRED NO_MODULE)
find_package(PkgConfig REQUIRED)
find_package(AsteroidApp6 REQUIRED)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ASTEROID_MODULE_PATH} ${CMAKE_SOURCE_DIR}/cmake)

include(FeatureSummary)
include(GNUInstallDirs)
include(ECMFindQmlModule)
include(Asteroid6CMakeSettings)
include(Asteroid6Translations)

find_package(Qt6 COMPONENTS REQUIRED Quick WaylandCompositor DBus)
find_package(Lipstick REQUIRED)
find_package(Timed REQUIRED)
pkg_check_modules(mlite6 REQUIRED mlite6)

ecm_find_qmlmodule(org.nemomobile.calendar 1.0 REQUIRED)
ecm_find_qmlmodule(org.nemomobile.systemsettings 1.0 REQUIRED)
ecm_find_qmlmodule(Nemo.Mce 1.0 REQUIRED)
ecm_find_qmlmodule(Nemo.DBus 2.0 REQUIRED)
ecm_find_qmlmodule(Nemo.Configuration 1.0 REQUIRED)
ecm_find_qmlmodule(Nemo.Time 1.0 REQUIRED)
ecm_find_qmlmodule(Nemo.Ngf 1.0 REQUIRED)
ecm_find_qmlmodule(Qt5Compat.GraphicalEffects 1.0 REQUIRED)
ecm_find_qmlmodule(QtMultimedia 1.0 REQUIRED)

add_subdirectory(src)

build_translations(i18n)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
