Summary: yadt broadcast service
Name: yadtbroadcast-service
Version: 1.0.9
Release: 1
License: GPL
Vendor: Immobilien Scout GmbH
Packager: arne.hilmann@gmail.com
Group: is24
Source0: %{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
BuildArch: noarch
Requires: yadtbroadcast-server

%description
provides an init script for the yadtbroadcast-server

%prep
%setup

%install
rm -rf  %{buildroot}
mkdir -p %{buildroot}
cp -av src/* %{buildroot}/
find %{buildroot} -type f -printf "/%%P\n" >files.lst

%files -f files.lst
%defattr(-,root,root,0755)

%pre

%post
/sbin/chkconfig --add yadtbroadcast-service

%postun
/sbin/chkconfig --del yadtbroadcast-service

%clean
%{__rm} -rf %{buildroot}
