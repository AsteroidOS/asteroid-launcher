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

target_link_libraries(asteroid-launcher PRIVATE
	Qt5::Quick
	Qt5::WaylandCompositor
	Qt5::DBus
	Mlite5::Mlite5
	Lipstick::Lipstick
	Timed::Timed)

install(TARGETS asteroid-launcher
	DESTINATION ${CMAKE_INSTALL_BINDIR})

install(DIRECTORY watchfaces
	DESTINATION ${CMAKE_INSTALL_DATADIR}/asteroid-launcher)
install(DIRECTORY watchfaces-img
	DESTINATION ${CMAKE_INSTALL_DATADIR}/asteroid-launcher)
install(DIRECTORY watchfaces-preview
	DESTINATION ${CMAKE_INSTALL_DATADIR}/asteroid-launcher)
install(DIRECTORY applauncher
	DESTINATION ${CMAKE_INSTALL_DATADIR}/asteroid-launcher)
