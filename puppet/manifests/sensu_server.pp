$rabbitmq_admin_user       = hiera('rabbitmq_admin_user', 'admin')
$rabbitmq_admin_password   = hiera('rabbitmq_admin_password', 'admin')
$sensu_default_mailfrom    = hiera('sensu_default_mailfrom', 'sensu+alerts@localhost')
$sensu_default_smtp_server = hiera('sensu_default_smtp_server', 'localhost')
$sensu_default_smtp_port   = hiera('sensu_default_smtp_port', '25')
$sensu_default_smtp_domain = hiera('sensu_default_smtp_domain', 'localhost')
$sensu_server_hostname     = hiera('sensu_server_hostname', 'localhost')
#$sensu_rabbitmq_user       = hiera('sensu::rabbitmq_user', 'sensu')
#$sensu_rabbitmq_password   = hiera('sensu::rabbitmq_password', 'sensu')
#$sensu_rabbitmq_vhost      = hiera('sensu::rabbitmq_vhost', '/sensu')

include '::sensu'
include '::rabbitmq'

# install self signed certs & key for rabbitmq
file { 'server_ssl.key':
  ensure  => present,
  require => Package['rabbitmq-server'],
  owner   => 'root',
  group   => 'rabbitmq',
  mode    => '0640',
  path    => '/etc/rabbitmq/ssl/server-key.pem',
  source  => '/vagrant/tools/ssl_certs/server/server-key.pem',
  notify  => Service['rabbitmq-server'],
}

file { 'server-cert.pem':
  ensure  => present,
  require => Package['rabbitmq-server'],
  owner   => 'root',
  group   => 'rabbitmq',
  mode    => '0644',
  path    => '/etc/rabbitmq/ssl/server-cert.pem',
  source  => '/vagrant/tools/ssl_certs/server/server-cert.pem',
  notify  => Service['rabbitmq-server'],
}

file { 'ca-cert.pem':
  ensure  => present,
  require => Package['rabbitmq-server'],
  owner   => 'root',
  group   => 'rabbitmq',
  mode    => '0644',
  path    => '/etc/rabbitmq/ssl/ca-cert.pem',
  source  => '/vagrant/tools/ssl_certs/sensu_ca/cacert-sensu.pem',
  notify  => Service['rabbitmq-server'],
}

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
  'bash-completion',
  'bsd-mailx',
  'curl',
  'dnsutils',
  'git',
  'ldap-utils',
  'nagios-plugins',
  'postfix',
  'redis-server',
  'unzip',
  'vim',
  'wget',
  ]:
  ensure => 'installed',
}

# required gems for various sensu checks
package { [
  'carrot-top',
  'mail',
  'redis',
  'rest-client',
  'timeout',
  'sensu-cli',
  ]:
  ensure   => 'installed',
  provider => sensu_gem,
}


augeas { 'postfix-relay':
  context => '/files/etc/postfix/main.cf',
  changes => 'set relayhost smtp.wm.edu',
}

#class {'apt':}

apt::source { 'flapjack':
  location => 'http://packages.flapjack.io/deb/v1',
  include  => {
    src => false,
  },
  repos    => 'main',
  key      => {
    'id' => '8406B0E3803709B6'
  },
}

package { 'flapjack':
  ensure  => 'present',
  require => [ [Apt::Source['flapjack'],], Class['sensu']],
}

rabbitmq_vhost { $::sensu::rabbitmq_vhost:
  ensure => present,
}

rabbitmq_user { $::sensu::rabbitmq_user:
  admin    => false,
  password => $::sensu::rabbitmq_password,
}

rabbitmq_user_permissions { "${::sensu::rabbitmq_user}@${::sensu::rabbitmq_vhost}":
  configure_permission => '.*',
  read_permission      => '.*',
  write_permission     => '.*',
}

# admin user for login to rabbitmq website on port 15672
rabbitmq_user { $rabbitmq_admin_user:
  admin    => true,
  password => $rabbitmq_admin_password,
}

#class { 'sensu':
#  rabbitmq_ssl_private_key => '/etc/sensu/ssl/client-key.pem',
#  rabbitmq_ssl_cert_chain  => '/etc/sensu/ssl/client-cert.pem',
#  require                  => [ Package['redis-server'], Class['::rabbitmq'] ],
#}

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

#### sensu handler definitions

# default handler set
sensu::handler { 'default':
  type     => 'set',
  command  => true,
  handlers => [ 'flapjack', 'mailer' ],
}

# individual handler definitions

# setup flapjack handler config
file { 'flapjack.json':
  ensure  => present,
  path    => '/etc/sensu/conf.d/handlers/flapjack.json',
  owner   => 'sensu',
  group   => 'sensu',
  mode    => '0644',
  content => '
{
  "flapjack": {
    "host": "localhost",
    "port": 6380,
    "db": "0"
  }
}
',
}

# mailer handler config
sensu::handler { 'mailer':
  type    => 'pipe',
  command => '/opt/etc/sensu/handlers/notification/mailer.rb',
  config  => {
    mail_from    => $sensu_default_mailfrom,
    mail_to      => [ 'vagrant@localhost', 'root@localhost' ],
    smtp_address => $sensu_default_smtp_server,
    smtp_port    => $sensu_default_smtp_port,
    smtp_domain  => $sensu_default_smtp_domain,
  }
}

#### end of sensu handlers

class { 'apache': }

class { '::apache::mod::auth_cas':
  cas_login_url    => 'https://cas.wm.edu/cas/login',
  cas_validate_url => 'https://cas.wm.edu/cas/serviceValidate',
  cas_cookie_path  => '/var/www/cas_cookies/',
}

apache::vhost { 'flapjack':
  servername      => 'flapjack',
  docroot         => '/var/www/html',
  port            => 80,
  proxy_pass      => [ {
    'path' => '/',
    'url'  => 'http://localhost:3080/'
  }, ],
  custom_fragment => '
  <Location />
    Authtype CAS
    require valid-user
  </Location>
  ',
}


# eof
