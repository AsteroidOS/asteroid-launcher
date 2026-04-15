set(SRC
	main.cpp
	applauncherbackground.cpp
	firstrun.cpp
	gesturefilterarea.cpp
	launcherlocalemanager.cpp
	applauncher.cpp
	notificationsnoozer.cpp)
set(HEADERS
	applauncherbackground.h
	firstrun.h
	gesturefilterarea.h
	launcherlocalemanager.h
	applauncher.h
	notificationsnoozer.h)

add_executable(asteroid-launcher ${SRC} ${HEADERS} resources-qml.qrc)

target_link_libraries(
	asteroid-launcher
	PRIVATE
		Qt6::Quick
		Qt6::WaylandCompositor
		Qt6::DBus
		Lipstick::Lipstick
		Timed::Timed
		${mlite6_LIBRARIES}
)
target_include_directories(asteroid-launcher PRIVATE ${mlite6_INCLUDE_DIRS})

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
	DIRECTORY applauncher
	DESTINATION ${CMAKE_INSTALL_DATADIR}/asteroid-launcher
)
