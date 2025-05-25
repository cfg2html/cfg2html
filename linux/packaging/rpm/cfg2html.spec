# I hope these variable are replaced by the make process .... ##TODO##FIXME## 20150212 by Ralph Roth
%define rpmrelease .git202502281559

%if %{?rpmrelease:1}%{!?rpmrelease:0}
%define gittag -%(c=%{rpmrelease}; echo ${c:1})
%endif

### Work-around the fact that OpenSUSE/SLES _always_ defined both :-/
%if 0%{?sles_version} == 0
%undefine sles_version
%endif
### Recently in CentOS8, RHEL8, etc, rpmbuild's macros now check for a proper shebang (#!) in the 1st line
### of the scripts.  Since our scripts are callable by bash, and ksh, we don't have a shebang in our
### scripts. This disables that checking.  #modified on 20201115 by edrulrd
%undefine __brp_mangle_shebangs

Name:		cfg2html
Version: 7.1.2
Release:	1%{?rpmrelease}%{?dist}
Summary:	Config2HTML is a tool to collect system information in HTML and ASCII format

Group:		Applications/File
License:	GPL-3.0-or-later
URL:		http://www.cfg2html.com/
Source: cfg2html-%{version}%{?gittag}.tar.gz
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
BuildArch:	noarch

BuildRequires:	make
Requires:	bash gawk psmisc coreutils
%if 0%{?rhel}
%if 0%{?rhel} < 8
Requires:	crontabs
%else
Requires:	crontabs or cron or cronie or anacron
%endif
%else
Requires:	crontabs or cron or cronie or anacron
%endif
Conflicts:	cfg2html-linux

%description
Swiss army knife script for the System Administrators as it was primarily written to get the necessary information to plan an update, or to perform basic trouble shooting or performance analysis.

%prep
%setup -q -n cfg2html-%{version}%{gittag}


%build


%install
%{__rm} -rf %{buildroot}
%{__make} -C linux install DESTDIR="%{buildroot}"

%if "%{_sbindir}" == "%{_bindir}"
mv %{buildroot}/usr/sbin %{buildroot}/usr/bin
%endif

# Post install procedure called at end of package installation # added on 20250222 by edrulrd
%post
%{_sourcedir}/linux/cfg2html.postinst

%clean
%{__rm} -rf %{buildroot}


%files
%defattr(-, root, root, 0755)

# linux/doc/*.html   {regression after deleting the .html :-( }
%doc linux/AUTHORS linux/COPYING linux/README linux/doc/*.txt

%doc %{_mandir}/man8/cfg2html.8*
%config(noreplace) %{_sysconfdir}/cron.d/%{name}
%config(noreplace) %{_sysconfdir}/cfg2html/
%{_datadir}/cfg2html/
%{_localstatedir}/log/cfg2html/
%{_sbindir}/cfg2html

## !! error: bad date in %changelog: 21.02.2025 Ralph Roth
## The correct format should be `Day Mon DD YYYY` (e.g., `Fri Feb 21 2025`)

%changelog
* Fri Feb 21 2025 Ralph Roth <cfg2html@hotmail.com> - 7.1.4
  - fixes for cron(tab)
  - fix for the RPM changelog

* Tue Dec 31 2024 Frank Crawford <frank@crawford.emu.id.au> - 7.1.2-1
  - upstream update
  - clean up spec file

* Thu Jan 05 2023 Frank Crawford <frank@crawford.emu.id.au> - 6.43
  - SPDX licences update
  - Fix up comments

* Wed May  29 2013 Gratien D'haese <gratien.dhaese@gmail.com> - 6.0
  - update cron lines

* Wed May  01 2013 Gratien D'haese <gratien.dhaese@gmail.com>
  - initial spec file for cfg2html
