# Define: sudo::alias
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
#    sudo::alias { 'ADMINS':
#        ensure        => present,
#        alias_type    => 'User_Alias',
#        alias_name    => 'ADMINS',
#        alias_content => 'jsmith, mikem',
#    }
#
define sudo::alias (
  $ensure         = present,
  $alias_type     = undef,
  $alias_name     = undef,
  $alias_content  = undef,
  $sudo_file      = 'sudoers',
  $sudo_file_path = '/etc'
) {

  validate_re($ensure, [present, absent])
  validate_re($alias_type, ['Host_Alias', 'User_Alias', 'Cmnd_Alias'])
  validate_string($alias_name)
  validate_string($alias_content)
  validate_string($sudo_file)
  validate_absolute_path($sudo_file_path)

  if ! ($ensure in [present, absent]) {
    fail('ensure parameter must be present or absent')
  }

  if ! ($alias_type in ['Host_Alias', 'User_Alias', 'Cmnd_Alias']) {
    fail('alias_type parameter must be "Host_Alias" or "User_Alias" or "Cmnd_Alias"')
  }

  if ($alias_type != undef and $alias_name != undef and $alias_content != undef) {
    $alias_line = "$alias_type $alias_name = $alias_content"
  }

  if ($alias_line != undef) {
    exec { "test_alias_exist_$name":
      command => "sed -i '/^$alias_type $alias_name[[:space:]]/d' ${sudo_file_path}/${sudo_file}",
      onlyif  => "grep \'^$alias_type[[:space:]]$alias_name[[:space:]]\' ${sudo_file_path}/${sudo_file} >/dev/null && cat ${sudo_file_path}/${sudo_file} |grep \'^$alias_type[[:space:]]$alias_name[[:space:]]\' |grep -v \'^$alias_line\$\' >/dev/null",
    }
    file_line { "alias_$name":
      ensure => $ensure,
      line   => $alias_line,
      path   => "${sudo_file_path}/${sudo_file}",
    }
  Exec["test_alias_exist_$name"] -> File_line["alias_$name"]
  }

}
