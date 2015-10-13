# == Class: shibboleth_v3
#
# This class to install and configure Shibboleth V3 server
#
# === Parameters
#
# $version:: The version of Shibboleth to download (for V3 versions only).
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# == Requires:
#
# Java
# Jetty
#
# === Examples
#
#   class {'shibboleth_v3':
#     version => '3.1.2',
#   }
#
# === Authors
#
# Dmitry Vaghin <dmitry.vaghin@cybera.ca>
#
# === Copyright
#
# Copyright 2015 Dmitry Vaghin, unless otherwise noted.
#
class shibboleth_v3 (
  $version                = hiera('shibboleth::version'),
  $tmp                    = hiera('shibboleth::tmp', '/tmp'),
) {
  

  exec { 'download shibboleth':
    cwd     => $tmp,
    path    => '/bin:/usr/bin',
    command => "wget http://shibboleth.net/downloads/identity-provider/${version}/shibboleth-identity-provider-${version}.zip",
    creates => "${tmp}/shibboleth-identity-provider-${version}.zip",
    notify  => Exec['unzip shibboleth'],
    require => Package['wget'],
  }

  exec { 'unzip shibboleth':
    cwd     => $tmp,
    path    => '/bin:/usr/bin',
    command => "unzip shibboleth-identity-provider-${version}.zip -d /opt",
    creates => "/opt/shibboleth-identity-provider-${version}.zip",
    require => Package['unzip'],
  }

}
