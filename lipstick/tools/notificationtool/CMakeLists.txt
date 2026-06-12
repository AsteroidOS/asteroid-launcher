set(NOTIFICATIONTOOL_SRC notificationtool.cpp)

set_source_files_properties(../../src/notifications/notificationmanager.xml PROPERTIES
	CLASSNAME NotificationManagerProxy
	INCLUDE lipsticknotification.h)
qt6_add_dbus_interface(NOTIFICATIONTOOL_SRC ../../src/notifications/notificationmanager.xml
	notificationmanagerproxy)

add_executable(notificationtool ${NOTIFICATIONTOOL_SRC})

target_link_libraries(notificationtool PRIVATE lipstick)

install(TARGETS notificationtool DESTINATION ${CMAKE_INSTALL_BINDIR})
