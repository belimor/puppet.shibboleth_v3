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
  $version                = hiera('shibboleth::version', '3.1.2'),
  $tmp                    = hiera('shibboleth::tmp', '/tmp'),
  $jce_unlimited_strength = hiera('shibboleth::jce_unlimited_strength', true),
  $key_store_pwd          = hiera('shibboleth::key_store_pwd', 'password-123'),
  $sealer_pwd             = hiera('shibboleth::sealer_pwd', 'password-123'),
  $host_name              = hiera('shibboleth::hostname', $::fqdn),
  $scope                  = hiera('shibboleth::scope', 'localscope'),
) {

  contain jetty

  singleton_packages('wget')
  
## Downloading and extracting Shibboleth files
  file { '/opt/install':
    ensure => directory,
  }

  exec { 'download shibboleth':
    logoutput => true,
    cwd     => "/opt/install",
    path    => '/bin:/usr/bin',
    unless  => "test -f /opt/install/shibboleth-identity-provider-${version}.tar.gz",
    command => "wget http://shibboleth.net/downloads/identity-provider/${version}/shibboleth-identity-provider-${version}.tar.gz",
    creates => "/opt/install/shibboleth-identity-provider-${version}.tar.gz",
    notify  => Exec['extract shibboleth'],
    require => [ Package['wget'], File['/opt/install'], ]
  }

  exec { 'extract shibboleth':
    logoutput => true,
    cwd     => "/opt/install",
    path    => '/bin:/usr/bin',
    unless  => "test -f /opt/install/shibboleth-identity-provider-${version}/bin/install.sh",
    command => "/bin/tar -zxvf /opt/install/shibboleth-identity-provider-${version}.tar.gz -C /opt/install",
    creates => "/opt/install/shibboleth-identity-provider-${version}.zip",
    require => File['/opt/install'],
  }

## Java Cryptography Extension Inlimited Strengh files
  if ( $jce_unlimited_strength ) {
    file { 'local_policy':
      ensure  => file,
      path    => "/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/security/local_policy.jar",
      source  => "puppet:///modules/shibboleth_v3/UnlimitedJCEPolicyJDK8/local_policy.jar",
      mode    => '0644',
      require => Class['jetty'],
    }

    file { 'US_export_policy':
      ensure  => file,
      path    => "/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/security/US_export_policy.jar",
      source  => "puppet:///modules/shibboleth_v3/UnlimitedJCEPolicyJDK8/US_export_policy.jar",
      mode    => '0644',
      require => Class['jetty'],
    }
  }

## Build shibboleth war file
  exec { 'shibboleth install':
    cwd         => "/opt/install",
    path        => '/bin:/usr/bin',
    logoutput   => true,
    unless      => "test -f /opt/shibboleth-idp/war/idp.war",
    environment => [ "JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64" ],
    command     => "/opt/install/shibboleth-identity-provider-${version}/bin/install.sh -Didp.src.dir=/opt/install/shibboleth-identity-provider-${version} -Didp.target.dir=/opt/shibboleth-idp -Didp.keystore.password=${key_store_pwd} -Didp.sealer.password=${sealer_pwd} -Didp.host.name=${host_name} -Didp.scope=${scope} -Dentityid=https://${host_name}/idp/shibboleth > /opt/install/inst_shibb.log 2>&1",
    require     => Exec['extract shibboleth'],
  }



}
