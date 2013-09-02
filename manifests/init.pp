# Define: sudo
#
#   This module manage sudo file(/etc/sudoers).
#
# Parameters:
#
# Actions:
#
# Requires:
#
#   puppetlabs-stdlib
#
# Sample Usage:
#
#    sudo { ['user', 'group']: }
#
#    sudo {['user1", 'usr2', 'group1']: ensure => absent}
#
#    sudo { 'ADMINS':
#        alias_hash => {
#            'ADMINS' => {
#                ensure        => present,
#                alias_type    => 'User_Alias',
#                alias_name    => 'ADMINS',
#                alias_content => 'jsmith, mikem, jobs',
#            },
#            'FILESERVERS' => {
#                ensure        => present,
#                alias_type    => 'Host_Alias',
#                alias_name    => 'FILESERVERS',
#                alias_content => 'fs1, fs2',
#            },
#        },
#        machine => 'FILESERVERS',
#    }
#
define sudo (
  $ensure            = present,
  $alias_hash        = 'unset',
  $machine           = 'ALL',
  $commands          = '(ALL)',
  $nopasswd          = true,
  $nopasswd_commands = 'ALL',
  $sudo_file         = 'sudoers',
  $sudo_file_path    = '/etc'
) {

  validate_re($ensure, [present, absent])
  validate_string($machine)
  validate_string($commands)
  validate_bool($nopasswd)
  validate_string($nopasswd_commands)
  validate_string($sudo_file)
  validate_absolute_path($sudo_file_path)

  if ($alias_hash != 'unset') {
    create_resources('sudo::alias', $alias_hash)
  }

  if $nopasswd == true {
    $nopwd = 'NOPASSWD'
    $line = "$name	$machine=$commands	${nopwd}: $nopasswd_commands"
  } else {
    $line = "$name	$machine=$commands	$commands"
  }

  exec { "test_user_exist_$name":
    command => "sed -i '/^$name[[:space:]]/d' ${sudo_file_path}/${sudo_file}",
    onlyif  => "grep \'^$name[[:space:]]\' ${sudo_file_path}/${sudo_file} >/dev/null && cat ${sudo_file_path}/${sudo_file} |grep \'^$name[[:space:]]\' |grep -v \'^$line\$\' >/dev/null",
  }

  file_line { "$name":
    ensure => $ensure,
    line   => $line,
    path   => "${sudo_file_path}/${sudo_file}",
  }

  Exec["test_user_exist_$name"] -> File_line["$name"]

}
