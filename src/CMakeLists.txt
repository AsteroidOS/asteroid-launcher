set(SRC
	main.cpp
	applauncherbackground.cpp
	firstrun.cpp
	gesturefilterarea.cpp
	applauncher.cpp
	notificationsnoozer.cpp)
set(HEADERS
	applauncherbackground.h
	firstrun.h
	gesturefilterarea.h
	applauncher.h
	notificationsnoozer.h)

add_executable(asteroid-launcher ${SRC} ${HEADERS} resources-qml.qrc)

set(QML_FILES
	qml/MainScreen.qml
	qml/today/Today.qml
	qml/today/weathericons.js
	qml/compositor/compositor.qml
	qml/compositor/WindowWrapperBase.qml
	qml/compositor/CircleMaskShader.qml
	qml/misc/Splash.qml
	qml/misc/PanelsGrid.qml
	qml/misc/ShutdownScreen.qml
	qml/misc/BluetoothAgent.qml
	qml/misc/desktop.js
	qml/notifications/NotificationActions.qml
	qml/notifications/NotificationButton.qml
	qml/notifications/NotificationIndicator.qml
	qml/notifications/NotificationView.qml
	qml/notifications/NotificationsPanel.qml
	qml/notifications/NotificationPreview.qml
	qml/quickpanel/QuickPanel.qml
	qml/quickpanel/QuickPanelToggle.qml
	qml/firstrun/FakeAlarmclock.qml
	qml/firstrun/FirstRunConfig.qml
	qml/firstrun/Tutorial.qml
)

set_source_files_properties(qml/MainScreen.qml                       PROPERTIES QT_RESOURCE_ALIAS MainScreen.qml)
set_source_files_properties(qml/today/Today.qml                      PROPERTIES QT_RESOURCE_ALIAS Today.qml)
set_source_files_properties(qml/today/weathericons.js                PROPERTIES QT_RESOURCE_ALIAS weathericons.js)
set_source_files_properties(qml/compositor/compositor.qml            PROPERTIES QT_RESOURCE_ALIAS compositor.qml)
set_source_files_properties(qml/compositor/WindowWrapperBase.qml     PROPERTIES QT_RESOURCE_ALIAS compositor/WindowWrapperBase.qml)
set_source_files_properties(qml/compositor/CircleMaskShader.qml      PROPERTIES QT_RESOURCE_ALIAS compositor/CircleMaskShader.qml)
set_source_files_properties(qml/misc/Splash.qml                      PROPERTIES QT_RESOURCE_ALIAS Splash.qml)
set_source_files_properties(qml/misc/PanelsGrid.qml                  PROPERTIES QT_RESOURCE_ALIAS PanelsGrid.qml)
set_source_files_properties(qml/misc/ShutdownScreen.qml              PROPERTIES QT_RESOURCE_ALIAS system/ShutdownScreen.qml)
set_source_files_properties(qml/misc/BluetoothAgent.qml              PROPERTIES QT_RESOURCE_ALIAS connectivity/BluetoothAgent.qml)
set_source_files_properties(qml/misc/desktop.js                      PROPERTIES QT_RESOURCE_ALIAS desktop.js)
set_source_files_properties(qml/notifications/NotificationActions.qml   PROPERTIES QT_RESOURCE_ALIAS NotificationActions.qml)
set_source_files_properties(qml/notifications/NotificationButton.qml    PROPERTIES QT_RESOURCE_ALIAS NotificationButton.qml)
set_source_files_properties(qml/notifications/NotificationIndicator.qml PROPERTIES QT_RESOURCE_ALIAS NotificationIndicator.qml)
set_source_files_properties(qml/notifications/NotificationView.qml      PROPERTIES QT_RESOURCE_ALIAS NotificationView.qml)
set_source_files_properties(qml/notifications/NotificationsPanel.qml    PROPERTIES QT_RESOURCE_ALIAS NotificationsPanel.qml)
set_source_files_properties(qml/notifications/NotificationPreview.qml   PROPERTIES QT_RESOURCE_ALIAS notifications/NotificationPreview.qml)
set_source_files_properties(qml/quickpanel/QuickPanel.qml            PROPERTIES QT_RESOURCE_ALIAS QuickPanel.qml)
set_source_files_properties(qml/quickpanel/QuickPanelToggle.qml      PROPERTIES QT_RESOURCE_ALIAS QuickPanelToggle.qml)
set_source_files_properties(qml/firstrun/FakeAlarmclock.qml          PROPERTIES QT_RESOURCE_ALIAS FakeAlarmclock.qml)
set_source_files_properties(qml/firstrun/FirstRunConfig.qml          PROPERTIES QT_RESOURCE_ALIAS FirstRunConfig.qml)
set_source_files_properties(qml/firstrun/Tutorial.qml                PROPERTIES QT_RESOURCE_ALIAS Tutorial.qml)

asteroid_app_qml_module(asteroid-launcher ${QML_FILES})

qt_add_shaders(
    asteroid-launcher "asteroid-launcher_shaders"
    FILES
        "qml/compositor/circlemaskshader.frag"
        "shaders/masked-spartan.frag"
)

target_link_libraries(
	asteroid-launcher
	PRIVATE
		Qt6::Quick
		Qt6::WaylandCompositor
		Qt6::DBus
		lipstick
		Timed::Timed
		PkgConfig::mlite6
)

install(
	TARGETS asteroid-launcher
	DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(
	DIRECTORY watchfaces
	DESTINATION ${CMAKE_INSTALL_DATADIR}/asteroid-launcher
)
install(
	DIRECTORY watchfaces-img
	DESTINATION ${CMAKE_INSTALL_DATADIR}/asteroid-launcher
)
install(
	DIRECTORY watchfaces-preview
	DESTINATION ${CMAKE_INSTALL_DATADIR}/asteroid-launcher
)
install(
	DIRECTORY shaders
	DESTINATION ${CMAKE_INSTALL_DATADIR}/asteroid-launcher
)
install(
	DIRECTORY applauncher
	DESTINATION ${CMAKE_INSTALL_DATADIR}/asteroid-launcher
)
