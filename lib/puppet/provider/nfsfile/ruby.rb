Puppet::Type.type(:nfsfile).provide(:ruby) do
  commands :runuser => '/usr/sbin/runuser'

  def create_dir(path, manage_as)
    runuser(['-u', manage_as, '--', 'mkdir', path])
  rescue Puppet::ExecutionFailure => e
    Puppet.debug("#create_file had an error -> #{e.inspect}")
  end

  def create_file(path, manage_as, is_directory)
    if !is_directory
      begin
        runuser(['-u', manage_as, '--', 'touch', path])
      rescue Puppet::ExecutionFailure => e
        Puppet.debug("#create_file had an error -> #{e.inspect}")
      end
    else
      create_dir(path, manage_as)
    end
  end

  def set_owner(path, manage_as, owner)
    runuser(['-u', manage_as, '--', 'chown', owner, path])
  rescue Puppet::ExecutionFailure => e
    Puppet.debug("#set_owner had an error -> #{e.inspect}")
  end

  def set_group(path, manage_as, group)
    runuser(['-u', manage_as, '--', 'chown', ":#{group}", path])
  rescue Puppet::ExecutionFailure => e
    Puppet.debug("#set_group had an error -> #{e.inspect}")
  end

  def set_mode(path, manage_as, mode)
    runuser(['-u', manage_as, '--', 'chmod', mode, path])
  rescue Puppet::ExecutionFailure => e
    Puppet.debug("#set_mode had an error -> #{e.inspect}")
  end

  def file_exists(path, manage_as, is_directory)
    if !is_directory
      begin
        runuser(['-u', manage_as, '--', 'test', '-f', path])
      rescue Puppet::ExecutionFailure
        return false
      end
    else
      begin
        runuser(['-u', manage_as, '--', 'test', '-d', path])
      rescue Puppet::ExecutionFailure
        return false
      end
    end
    true
  end

  def remove_file(path, manage_as)
    runuser(['-u', manage_as, '--', 'rm', '-rf', path])
  rescue Puppet::ExecutionFailure
    nil
  end

  def create_helper(path, manage_as, directory, owner, group, mode)
    create_file(path, manage_as, directory)
    set_owner(path, manage_as, owner) unless owner.nil?
    set_group(path, manage_as, group) unless group.nil?
    set_mode(mode, manage_as, mode) unless mode.nil?
  end

  def exists?
    file_exists(resource[:path], resource[:manage_as], resource[:directory])
  end

  def destroy
    remove_file(path, manage_as)
  end

  def create
    create_helper(resource[:path],
                  resource[:manage_as],
                  resource[:directory],
                  resource[:owner],
                  resource[:group],
                  resource[:mode])
  end

  def directory
    file_exists(resource[:path], resource[:manage_as], true) ? 'true' : 'false'
  end

  def owner
    runuser(['-u', resource[:manage_as], '--', 'stat', '--printf=%U', resource[:path]])
  rescue Puppet::ExecutionFailure
    nil
  end

  def owner=(value)
    set_owner(resource[:path], resource[:manage_as], value)
  end

  def group
    runuser(['-u', resource[:manage_as], '--', 'stat', '--printf=%G', resource[:path]])
  rescue Puppet::ExecutionFailure
    nil
  end

  def group=(value)
    set_owner(resource[:path], resource[:manage_as], value)
  end

  def mode
    runuser(['-u', resource[:manage_as], '--', 'stat', '--printf=0%a', resource[:path]])
  rescue Puppet::ExecutionFailure
    nil
  end

  def mode=(value)
    set_owner(resource[:path], resource[:manage_as], value)
  end
end
