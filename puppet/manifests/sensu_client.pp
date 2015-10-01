# install self signed certs for sensu to talk to rabbitmq with
file { 'client_ssl.key':
  ensure  => present,
  require => Package['sensu'],
  owner   => 'sensu',
  group   => 'sensu',
  mode    => '0640',
  path    => '/etc/sensu/ssl/client-key.pem',
  source  => '/vagrant/tools/ssl_certs/client/client-key.pem',
  notify  => Service['sensu-client'],
}

file { 'client-cert.pem':
  ensure  => present,
  require => Package['sensu'],
  owner   => 'sensu',
  group   => 'sensu',
  mode    => '0644',
  path    => '/etc/sensu/ssl/client-cert.pem',
  source  => '/vagrant/tools/ssl_certs/client/client-cert.pem',
  notify  => Service['sensu-client'],
}

package { [
  'git',
  'nagios-plugins',
  'unzip',
  'vim',
  'wget',
  ]:
  ensure => 'installed',
}

# required gems for various sensu checks
package { [
  'sensu-cli',
  ]:
  ensure   => 'installed',
  provider => sensu_gem,
  require  => Class['sensu'],
}

class {'apt':}

class { 'sensu':
  rabbitmq_ssl             => true,
  rabbitmq_ssl_private_key => '/etc/sensu/ssl/client-key.pem',
  rabbitmq_ssl_cert_chain  => '/etc/sensu/ssl/client-cert.pem',
}

file { '/opt/etc':
  ensure => directory,
  owner  => 'root',
  group  => 'root',
  mode   => '0755',
}

vcsrepo { '/opt/etc/sensu':
  ensure   => 'latest',
  provider => git,
  source   => 'https://github.com/crpeck/sensu-files.git',
  require  => [ Package['git'], File['/opt/etc'] ]
}

