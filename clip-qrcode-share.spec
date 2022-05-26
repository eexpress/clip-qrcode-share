Name:           clip-qrcode-share
Version:        0.2
Release:        1%{?dist}
Summary:        Sharing clipboard and files to mobile by scan QRCode.
BuildArch:      noarch

License:        GPL V3
URL:            https://github.com/eexpress/clip-qrcode-share
Source0:        %{name}-%{version}.tar.xz


Requires:       libadwaita>=1.1.0 gtk4>=4.6.0 cairo>=1.1 qrencode

%description
Sharing clipboard and files to mobile by scan QRCode.

%prep
%autosetup


%build
%configure
%make_build


%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/%{_bindir}
mkdir -p $RPM_BUILD_ROOT/%{_datadir}/applications
mkdir -p $RPM_BUILD_ROOT/%{_datadir}/pixmaps
cp %{name} $RPM_BUILD_ROOT/%{_bindir}
cp droopy $RPM_BUILD_ROOT/%{_bindir}
cp %{name}.desktop $RPM_BUILD_ROOT/%{_datadir}/applications
cp %{name}.png $RPM_BUILD_ROOT/%{_datadir}/pixmaps

%make_install

%files
%{_bindir}/%{name}
%{_bindir}/droopy
%{_datadir}/applications/%{name}.desktop
%{_datadir}/pixmaps/%{name}.png

%license add-license-file-here
%doc add-docs-here



%changelog
* Thu May 26 2022 eexpss <eexpss@gmail.com>
- 
