# Sudo module for Puppet

This module manages sudo on Linux (RedHat/Debian) distros. 

## Description

This module depends on the [puppetlabs-stdlib](https://github.com/puppetlabs/puppetlabs-stdlib).

## Usage

添加用户和组：

    sudo { ['user', 'group']: }

/etc/sudoers会添加如下行：

    user    FILESERVERS=(ALL)    NOPASSWD: ALL
    group    FILESERVERS=(ALL)    NOPASSWD: ALL

删除用户和组：

    sudo {['user1", 'usr2', 'group1']: ensure => absent}

使用别名添加ADMINS组：

    sudo { 'ADMINS':
        ensure => present,
        alias_hash => {
            'ADMINS' => {
                ensure        => present,
                alias_type    => 'User_Alias',
                alias_name    => 'ADMINS',
                alias_content => 'jsmith, mikem, jobs',
            },
            'FILESERVERS' => {
                ensure        => present,
                alias_type    => 'Host_Alias',
                alias_name    => 'FILESERVERS',
                alias_content => 'fs1, fs2',
            },
        },
        machine => 'FILESERVERS',
    }

上面命令会添加如下行：

    ADMINS  FILESERVERS=(ALL)       NOPASSWD: ALL
    User_Alias ADMINS = jsmith, mikem, jobs
    Host_Alias FILESERVERS = fs1, fs2

删除以上建立的别名只需将ensure都改为absent：

    sudo { 'ADMINS':
        ensure => absent,
        alias_hash => {
            'ADMINS' => {
                ensure        => absent,
                alias_type    => 'User_Alias',
                alias_name    => 'ADMINS',
                alias_content => 'jsmith, mikem, jobs',
            },
            'FILESERVERS' => {
                ensure        => absent,
                alias_type    => 'Host_Alias',
                alias_name    => 'FILESERVERS',
                alias_content => 'fs1, fs2',
            },
        },
        machine => 'FILESERVERS',
    }