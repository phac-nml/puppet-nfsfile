Puppet::Type.type(:nfsfile).provide(:ruby) do
  commands :runuser => '/usr/sbin/runuser'

  def create_file(path, manage_as, is_directory)
    if not is_directory
      begin
        runuser(['-u', manage_as, '--', 'touch', path])
      rescue Puppet::ExecutionFailure => e
        Puppet.debug("#create_file had an error -> #{e.inspect}")
        return nil
      end
    else
      begin
        runuser(['-u', manage_as, '--', 'mkdir', path])
      rescue Puppet::ExecutionFailure => e
        Puppet.debug("#create_file had an error -> #{e.inspect}")
        return nil
      end
    end
  end

  def set_owner(path, manage_as, owner)
    begin
      runuser(['-u', manage_as, '--', 'chown', owner, path])
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("#set_owner had an error -> #{e.inspect}")
      return nil
    end
  end

  def set_group(path, manage_as, group)
    begin
      runuser(['-u', manage_as, '--', 'chown', ":#{group}", path])
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("#set_group had an error -> #{e.inspect}")
      return nil
    end
  end

  def set_mode(path, manage_as, mode)
    begin
      runuser(['-u', manage_as, '--', 'chmod', mode, path])
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("#set_mode had an error -> #{e.inspect}")
      return nil
    end
  end

  def file_exists(path, manage_as, is_directory)
    if not is_directory
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
    begin
      runuser(['-u', manage_as, '--', 'rm', '-rf', path])
    rescue Puppet::ExecutionFailure
      return nil
    end
  end

  def create_helper(path, manage_as, directory, owner, group, mode)
    # create the file/directory
    return nil if create_file(path, manage_as, directory) == nil

    # set owner
    if owner != nil
      return nil if set_owner(path, manage_as, owner) == nil
    end

    # set group
    if group != nil
      return nil if set_group(path, manage_as, group) == nil
    end

    # set mode
    if mode != nil
      return nil if set_mode(mode, manage_as, mode) == nil
    end
  end

  def exists?
    file_exists(resource[:path], resource[:manage_as], resource[:directory])
  end

  def destroy
    remove_file(path, manage_as)
  end

  def create
    create_helper(resource[:path], resource[:manage_as], resource[:directory], resource[:owner], resource[:group], resource[:mode])
  end

  def owner
    begin
      user = runuser(['-u', manage_as, '--', 'stat', '--printf=%U', path])
    rescue Puppet::ExecutionFailure
      return nil
    end
    user
  end

  def owner=(value)
    set_owner(resource[:path], resource[:manage_as], value)
  end

  def group
    begin
      grp = runuser(['-u', manage_as, '--', 'stat', '--printf=%G', path])
    rescue Puppet::ExecutionFailure
      return nil
    end
    grp
  end

  def group=(value)
    set_owner(resource[:path], resource[:manage_as], value)
  end

  def mode
    begin
      md = runuser(['-u', manage_as, '--', 'stat', '--printf=0%a', path])
    rescue Puppet::ExecutionFailure
      return nil
    end
    md
  end

  def mode=(value)
    set_owner(resource[:path], resource[:manage_as], value)
  end
end
