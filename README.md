# nfsfile

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with nfsfile](#setup)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)

## Description

`nfsfile` adds a new type (`nfsfile`) which functions as a alternate version of
the `file` resource type with support for managing a file as a specific user
which is useful on network file systems where `root` doesn't necessarily have
access to every file. The feature-set is more limited than `file` but new
features can be added as needed. One major difference from `file` is that
choosing file/directory is separated from `ensure` (currently as a boolean).

## Setup

Install the module alongside all your other modules and the new type should
be useable in any puppet class.

## Usage

The main use case for this type is when you need to manage files on a network
file system where a service account has access to the directory but not root.
It can be used as such:

```puppet
nfsfile { 'resource title':
    ensure    => present,
    directory => true,
    owner     => service-account,
    group     => service-group,
    mode      => '0770',
    manage_as => service-account,
}
```

in which the directory created is managed by `service-account` instead of root.

## Limitations

The full feature-set of `file` is not supported as of right now. Managing a
file as a specific user means that Puppet has the same limitations as that user
while managing the file. This means that setting the owner of the file doesn't
really do anything (only root can change the owner) and the the group can only
be changed to one that `manage_as` is a member of.
