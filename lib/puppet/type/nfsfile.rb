Puppet::Type.newtype(:nfsfile) do
  desc 'Puppet type that manages files like the `file` type but can do so as a specific user'

  ensurable

  newparam(:path, namevar: :true) do
    desc 'The path to the file to manage. Must be fully qualified.'
  end

  newproperty(:directory) do
    desc 'Whether this file is a directory or not'
    newvalues(:true, :false)
  end

  newparam(:owner) do
    desc 'The user to whom the file should belong.'
  end

  newproperty(:group) do
    desc 'Which group should own the file.'
  end

  newproperty(:mode) do
    desc 'The desired permissions mode for the file in symbolic or numeric'\
    'notiation. This value must be specified as a string; do not use un-quoted'\
    'number so to represent file modes.'
    newvalues(/^0\d{3}/)
  end
end
