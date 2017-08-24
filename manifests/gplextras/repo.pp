# == Class: cloudera::gplextras::repo
#
# This class handles installing the Cloudera GPL Extras software repositories.
#
# === Parameters:
#
# [*ensure*]
#   Ensure if present or absent.
#   Default: present
#
# [*reposerver*]
#   URI of the YUM server.
#   Default: http://archive.cloudera.com
#
# [*repopath*]
#   The path to add to the $reposerver URI.
#   Only set this if your platform is not supported or you know what you are
#   doing.
#   Default: auto-set, platform specific
#
# [*version*]
#   The version of Cloudera GPL Extras to install.
#   Default: 4
#
# [*proxy*]
#   The URL to the proxy server for the YUM repositories.
#   Default: absent
#
# [*proxy_username*]
#   The username for the YUM proxy.
#   Default: absent
#
# [*proxy_password*]
#   The password for the YUM proxy.
#   Default: absent
#
# === Actions:
#
# Installs YUM repository configuration files.
#
# === Requires:
#
# Nothing.
#
# === Sample Usage:
#
#   class { 'cloudera::gplextras::repo':
#     version => '4.3.0',
#   }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2014 Mike Arnold, unless otherwise noted.
#
class cloudera::gplextras::repo (
  $ensure            = $cloudera::params::ensure,
  $reposerver        = $cloudera::params::cg_reposerver,
  $repopath          = $cloudera::params::cg_repopath,
  $version           = $cloudera::params::cg_version,
  $yum_repo_priority = $cloudera::params::yum_repo_priority,
  $yum_repo_protect  = $cloudera::params::yum_repo_protect,
  $aptkey            = $cloudera::params::cg_aptkey,
  $proxy             = $cloudera::params::proxy,
  $proxy_username    = $cloudera::params::proxy_username,
  $proxy_password    = $cloudera::params::proxy_password
) inherits cloudera::params {
  case $ensure {
    /(present)/: {
      $enabled = '1'
    }
    /(absent)/: {
      $enabled = '0'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  case $::operatingsystem {
    'CentOS', 'RedHat', 'OEL', 'OracleLinux': {
      yumrepo { 'cloudera-gplextras4':
        descr          => 'Cloudera GPL Extras',
        enabled        => $enabled,
        gpgcheck       => 1,
        gpgkey         => "${reposerver}${repopath}RPM-GPG-KEY-cloudera",
        baseurl        => "${reposerver}${repopath}${version}/",
        priority       => $yum_repo_priority,
        protect        => $yum_repo_protect,
        proxy          => $proxy,
        proxy_username => $proxy_username,
        proxy_password => $proxy_password,
      }

      file { '/etc/yum.repos.d/cloudera-gplextras4.repo':
        ensure => 'file',
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
      }

      Yumrepo['cloudera-gplextras4'] -> Package<|tag == 'cloudera-gplextras'|>
    }
    'SLES': {
      zypprepo { 'cloudera-gplextras4':
        descr       => 'Cloudera GPL Extras',
        enabled     => $enabled,
        gpgcheck    => 1,
        gpgkey      => "${reposerver}${repopath}RPM-GPG-KEY-cloudera",
        baseurl     => "${reposerver}${repopath}${version}/",
        autorefresh => 1,
        priority    => $yum_repo_priority,
      }

      file { '/etc/zypp/repos.d/cloudera-gplextras4.repo':
        ensure => 'file',
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
      }

      Zypprepo['cloudera-gplextras4'] -> Package<|tag == 'cloudera-gplextras'|>
    }
    'Debian', 'Ubuntu': {
      include '::apt'

      apt::source { 'cloudera-gplextras4':
        location     => "${reposerver}${repopath}",
        release      => "${::lsbdistcodename}-gplextras${version}",
        repos        => 'contrib',
        key          => $aptkey,
        key_source   => "${reposerver}${repopath}archive.key",
        architecture => $cloudera::params::architecture,
      }

      Apt::Source['cloudera-gplextras4'] -> Package<|tag == 'cloudera-gplextras'|>
    }
    default: { }
  }
}
