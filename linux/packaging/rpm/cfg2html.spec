# I hope these variable are replaced by the make process .... ##TODO##FIXME## 20150212 by Ralph Roth
%define rpmrelease .git201312020913

### Work-around the fact that OpenSUSE/SLES _always_ defined both :-/
%if 0%{?sles_version} == 0
%undefine sles_version
%endif
### Recently in CentOS8, RHEL8, etc, rpmbuild's macros now check for a proper shebang (#!) in the 1st line
### of the scripts.  Since our scripts are callable by bash, and ksh, we don't have a shebang in our
### scripts. This disables that checking.  #modifed on 20201115 by edrulrd
%undefine __brp_mangle_shebangs

Name:		cfg2html
Version: 6.16
Release:	1%{?rpmrelease}%{?dist}
Summary:	Config2HTML is a tool to collect system information in HTML and ASCII format

Group:		Applications/File
License:	GPLv3
URL:		http://www.cfg2html.com/
Source: cfg2html-6.16-git201312020913.tar.gz
#Source1:	%{name}.cron
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch:	noarch

#BuildRequires:	
Requires:	bash gawk psmisc
Conflicts:	cfg2html-linux

%description
Swiss army knife script for the System Administrators as it was primarily written to get the necessary information to plan an update, or to perform basic trouble shooting or performance analysis.

%prep
%setup -q -n cfg2html-6.16-git201312020913


%build


%install
%{__rm} -rf %{buildroot}
%{__make} -C linux install DESTDIR="%{buildroot}"
#%{__install} -Dp -m0644 %{name}.cron %{buildroot}%{_sysconfdir}/cron.d/%{name}

%clean
%{__rm} -rf %{buildroot}


%files
%defattr(-, root, root, 0755)
%doc linux/AUTHORS linux/COPYING linux/README linux/doc/*.txt linux/doc/*.html
%doc %{_mandir}/man8/cfg2html.8*
%config(noreplace) %{_sysconfdir}/cron.d/%{name}
%config(noreplace) %{_sysconfdir}/cfg2html/
%{_datadir}/cfg2html/
%{_localstatedir}/log/cfg2html/
%{_sbindir}/cfg2html


%changelog
* Wed May  29 2013 Gratien D'haese <gratien.dhaese@gmail.com> - 6.0
  update cron lines
* Wed May  01 2013 Gratien D'haese <gratien.dhaese@gmail.com>
  initial spec file for cfg2html
