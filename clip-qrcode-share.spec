Name:            clip-qrcode-share
Version:         0.3
Release:         1%{?dist}
Summary:         Sharing clipboard and files to mobile by scan QRCode.
BuildArch:       noarch
License:         GPLv3+
URL:             https://github.com/eexpress/clip-qrcode-share 
Source0:         %{name}-%{version}.tar.xz
Requires:        libadwaita gtk4 cairo qrencode

%description
Sharing clipboard and files to mobile by scan QRCode.

%define _binaries_in_noarch_packages_terminate_build   0

%install
cd %{_sourcedir}
cp -ar * %{buildroot}/

%files
%{_bindir}/clip-qrcode-share
%{_bindir}/droopy
%{_datadir}/applications/clip-qrcode-share.desktop
%{_datadir}/pixmaps/clip-qrcode-share.png


	
