Name:       lipstick-qt5

# We need this folder, so that lipstick can monitor it. See the code
# in src/components/launchermodel.cpp for reference.
%define icondirectory %{_datadir}/icons/hicolor/86x86/apps

Summary:    QML toolkit for homescreen creation
Version:    0.27.84
Release:    1
Group:      System/Libraries
License:    LGPLv2.1
URL:        http://github.com/nemomobile/lipstick
Source0:    %{name}-%{version}.tar.bz2
Requires:   mce >= 1.31.0
Requires:   pulseaudio-modules-nemo-mainvolume >= 6.0.19
Requires(post): /sbin/ldconfig
Requires(postun): /sbin/ldconfig
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Quick) >= 5.2.1
BuildRequires:  pkgconfig(Qt5Xml)
BuildRequires:  pkgconfig(Qt5Sql)
BuildRequires:  pkgconfig(Qt5SystemInfo)
BuildRequires:  pkgconfig(Qt5Test)
BuildRequires:  pkgconfig(Qt5Sensors)
BuildRequires:  pkgconfig(contentaction5)
BuildRequires:  pkgconfig(mlite5) >= 0.0.6
BuildRequires:  pkgconfig(mce) >= 1.16.0
BuildRequires:  pkgconfig(mce-qt5) >= 1.2.0
BuildRequires:  pkgconfig(keepalive)
BuildRequires:  pkgconfig(dsme_dbus_if) >= 0.63.2
BuildRequires:  pkgconfig(thermalmanager_dbus_if)
BuildRequires:  pkgconfig(usb_moded)
BuildRequires:  pkgconfig(dbus-1)
BuildRequires:  pkgconfig(dbus-glib-1)
BuildRequires:  pkgconfig(libresourceqt5)
BuildRequires:  pkgconfig(ngf-qt5)
BuildRequires:  pkgconfig(systemd)
BuildRequires:  pkgconfig(wayland-server)
BuildRequires:  pkgconfig(usb-moded-qt5) >= 1.1
BuildRequires:  qt5-qttools-linguist
BuildRequires:  qt5-qtgui-devel >= 5.2.1+git24
BuildRequires:  qt5-qtwayland-wayland_egl-devel >= 5.4.0+git26
BuildRequires:  doxygen
Conflicts:   meegotouch-systemui < 1.5.7
Obsoletes:   libnotificationsystem0

%description
A QML toolkit for homescreen creation

%package devel
Summary:    Development files for lipstick
License:    LGPLv2.1
Requires:   %{name} = %{version}-%{release}

%description devel
Files useful for building homescreens.

%package tests
Summary:    Tests for lipstick
License:    LGPLv2.1
Requires:   %{name} = %{version}-%{release}

%description tests
Unit tests for the lipstick package.

%package tools
Summary:    Tools for lipstick
License:    LGPLv2.1
Requires:   %{name} = %{version}-%{release}

%description tools
Tools for the lipstick package (warning: these tools installed by default).

%package screenshot
Summary:    Screenshot tool for lipstick
License:    LGPLv2.1
Requires:   %{name} = %{version}-%{release}
Requires:   %{name}-tools = %{version}-%{release}
Obsoletes:  lipstick-qt5-tools-ui
Provides:   lipstick-qt5-tools-ui

%description screenshot
Screenshot tool for the lipstick package.

%package simplecompositor
Summary:    Lipstick Simple Compositor
License:    LGPLv2.1
Requires:   %{name} = %{version}-%{release}

%description simplecompositor
Debugging tool to debug the compositor logic without pulling in all of the
homescreen and all the other app logic lipstick has.

%package doc
Summary:    Documentation for lipstick
License:    LGPLv2.1
Group:      Documentation
BuildArch:  noarch

%description doc
Documentation for the lipstick package.

%package notification-doc
Summary:    Documentation for lipstick notification services
License:    LGPLv2.1
Group:      Documentation
BuildArch:  noarch

%description notification-doc
Documentation for the lipstick notification services.

%package ts-devel
Summary:    Translation files for lipstick
License:    LGPLv2.1
Group:      Documentation
BuildArch:  noarch

%description ts-devel
Translation files for the lipstick package.

%prep
%setup -q -n %{name}-%{version}

%build

%qmake5 VERSION=%{version}

make %{?_smp_mflags}

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/%{icondirectory}
%qmake5_install


%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%defattr(-,root,root,-)
%config %{_sysconfdir}/dbus-1/system.d/lipstick.conf
%{_libdir}/liblipstick-qt5.so.*
%dir %{_libdir}/qt5/qml/org/nemomobile/lipstick
%{_libdir}/qt5/qml/org/nemomobile/lipstick/liblipstickplugin.so
%{_libdir}/qt5/qml/org/nemomobile/lipstick/qmldir
%{_datadir}/translations/lipstick_eng_en.qm
%dir %{_datadir}/lipstick
%dir %{_datadir}/lipstick/notificationcategories
%{_datadir}/lipstick/notificationcategories/*.conf
%{_datadir}/lipstick/androidnotificationpriorities
%dir %{icondirectory}

%files devel
%defattr(-,root,root,-)
%{_includedir}/lipstick-qt5/*.h
%{_libdir}/liblipstick-qt5.so
%{_libdir}/liblipstick-qt5.prl
%{_libdir}/pkgconfig/lipstick-qt5.pc

%files tests
%defattr(-,root,root,-)
/opt/tests/lipstick-tests/*

%files tools
%defattr(-,root,root,-)
%{_bindir}/notificationtool

%files screenshot
%defattr(-,root,root,-)
%{_bindir}/screenshottool
%{_datadir}/applications/screenshottool.desktop

%files simplecompositor
%defattr(-,root,root,-)
%{_bindir}/simplecompositor
%{_datadir}/lipstick/simplecompositor/*

%files doc
%defattr(-,root,root,-)
%{_datadir}/doc/lipstick/*

%files notification-doc
%defattr(-,root,root,-)
%{_datadir}/doc/lipstick-notification/*

%files ts-devel
%defattr(-,root,root,-)
%{_datadir}/translations/source/lipstick.ts
