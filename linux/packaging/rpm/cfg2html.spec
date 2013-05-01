Name:		cfg2html
Version: 6.0
Release:	1%{?dist}
Summary:	Config 2 HTML is a tool to collect system information in HTML and ASCII format

Group:		Applications/File
License:	GPLv3
URL:		http://cfg2html.com/
Source: http://www.it3.be/downloads/cfg2html/cfg2html-6.0-git201305011747.tar.gz
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

BuildRequires:	
Requires:	bash

%description
The cfg2html-linux script is the "swiss army knife" for the ASE, CE, sysadmin etc. I wrote it to get the necessary information to plan an update, to perform basic trouble shooting or performance analysis.

%prep
%setup -q -n cfg2html-6.0-git201305011747


%build


%install
%{__rm} -rf %{buildroot}
%{__make} install DESTDIR="%{buildroot}"
##%{__install} -Dp -m0644 cfg2html.cron %{buildroot}%{_sysconfdir}/cron.d/cfg2html

%clean
%{__rm} -rf %{buildroot}


%files
%defattr(-, root, root, 0755)
%doc AUTHORS COPYING README doc/*.txt
%doc %{_mandir}/man8/cfg2html.8*
##%config(noreplace) %{_sysconfdir}/cron.d/cfg2html/
%config(noreplace) %{_sysconfdir}/cfg2html/
%{_datadir}/cfg2html/
%{_localstatedir}/log/cfg2html/
%{_sbindir}/cfg2html


%changelog
* Wed May  01 2013 Gratien D'haese <gratien.dhaese@gmail.com>
