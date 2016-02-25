class nginx {

  case $::osfamily {
    'redhat', 'debian': {
      $pkgname = 'nginx'
      $owner = 'root'
      $group = 'root'
      $docroot = '/var/www'
      $confdir = '/etc/nginx'
      $logdir = '/var/log/nginx'
    }
     'windows': {
      $pkgname = 'nginx-service'
      $owner = 'Administrator'
      $group = 'Administrators'
      $docroot = 'C:/ProgramData/nginx/html'
      $confdir = 'C:/ProgramData/nginx'
      $logdir = 'C:/ProgramData/nginx/logs'
    }
    default : {
      fail("Module ${module_name} is not supported on ${::osfamily}") }
  }
  
  $runas = $::osfamily ? {
    'redhat' => 'nginx',
    'debian' => 'www-data',
    'windows' => 'nobody',
  }
  
  File {
    owner => $owner,
    group => $group,
    mode => '0644',
  }
  
  package { $pkgname:
    ensure => present,
  }
  
  file { $docroot:
    ensure => directory,
  }

  file { "${docroot}/index.html":
    ensure => file,
    source => 'puppet:///modules/nginx/index.html',
    require => Package[$pkgname],
  }
  
  file { "${confdir}/nginx.conf":
    ensure => file,
    content => template('nginx/nginx.conf.erb'),
    require => Package[$pkgname],
  }
  
  file { "${confdir}/conf.d/default.conf":
    ensure => file,
    content => template('nginx/default.conf.erb'),
    require => Package[$pkgname],
  }

  service { 'nginx':
    ensure => running,
    enable => true,
    subscribe => [File["${confdir}/nginx.conf"], File["${confdir}/conf.d/default.conf"]],
  }
  
}
