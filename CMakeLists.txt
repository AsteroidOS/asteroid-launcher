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

find_package(Qt6 COMPONENTS REQUIRED Quick WaylandCompositor DBus ShaderTools Sql Sensors)
find_package(Timed REQUIRED)
pkg_check_modules(mlite6 REQUIRED IMPORTED_TARGET mlite6)

# Dependencies of the bundled lipstick library (linked in lipstick/). The
# imported targets and variables are inherited by that subdirectory.
pkg_check_modules(mce REQUIRED IMPORTED_TARGET mce)
pkg_check_modules(mce-qt6 REQUIRED IMPORTED_TARGET mce-qt6)
pkg_check_modules(keepalive REQUIRED IMPORTED_TARGET keepalive)
pkg_check_modules(dbus-1 REQUIRED IMPORTED_TARGET dbus-1)
pkg_check_modules(dbus-glib-1 REQUIRED IMPORTED_TARGET dbus-glib-1)
# No IMPORTED_TARGET: ngf-qt6.pc advertises a bogus includedir (the headers
# actually live in the default include path) and CMake refuses to import it.
pkg_check_modules(ngf-qt6 REQUIRED ngf-qt6)
pkg_check_modules(libsystemd REQUIRED IMPORTED_TARGET libsystemd)
pkg_check_modules(dsme_dbus_if REQUIRED IMPORTED_TARGET dsme_dbus_if)
pkg_check_modules(thermalmanager_dbus_if REQUIRED IMPORTED_TARGET thermalmanager_dbus_if)
pkg_check_modules(usb-moded-qt6 REQUIRED IMPORTED_TARGET usb-moded-qt6)

ecm_find_qmlmodule(org.nemomobile.calendar 1.0)
ecm_find_qmlmodule(org.asteroid.settings 1.0)
ecm_find_qmlmodule(Nemo.Mce 1.0)
ecm_find_qmlmodule(Nemo.DBus 2.0)
ecm_find_qmlmodule(Nemo.Configuration 1.0)
ecm_find_qmlmodule(Nemo.Time 1.0)
ecm_find_qmlmodule(Nemo.Ngf 1.0)
ecm_find_qmlmodule(Qt5Compat.GraphicalEffects 1.0)

add_subdirectory(lipstick)
add_subdirectory(src)

build_translations(i18n)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
