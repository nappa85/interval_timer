Name:       harbour-interval-timer
Summary:    Interval training timer
Version:    0.1.3
Release:    1
License:    BSD-3-Clause
URL:        https://github.com/nappa85/interval_timer
Source0:    %{name}-%{version}.tar.bz2
Requires:   sailfishsilica-qt5 >= 0.10.9
Requires:   qt5-qtcore
Requires:   qt5-qtdeclarative
Requires:   qt5-qtmultimedia
Requires:   qt5-qtmultimedia-plugin-mediaservice-gstmediaplayer
Requires:   qt5-qtmultimedia-plugin-audio-pulseaudio
Requires:   nemo-qml-plugin-configuration-qt5
Requires:   nemo-qml-plugin-notifications-qt5
Requires:   qml(Nemo.KeepAlive)
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(Qt5Multimedia)
BuildRequires:  desktop-file-utils

%description
Interval training timer: configure how many sets, the set duration and the
rest duration, save and load presets, then run the workout. A fixed 5 second
countdown precedes the first set; every countdown beeps on its last 3
seconds and signals the phase change, with a dedicated end-of-workout sound.

%prep
%setup -q -n %{name}-%{version}

%build
%qmake5
make %{?_smp_mflags}

%install
rm -rf %{buildroot}
%qmake5_install

desktop-file-install --delete-original \
  --dir %{buildroot}%{_datadir}/applications \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_bindir}/%{name}
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png

%changelog
* Wed Aug 19 2026 Marco Napetti <marco.napetti@proton.me> - 1.0.0-1
- Initial release.
