# frozen_string_literal: true
Puppet::Type.type(:nfsfile).provide(:ruby) do
  commands runuser: '/usr/sbin/runuser'

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

  def exists?
    file_exists(resource[:path], resource[:manage_as], resource[:directory])
  end

  def destroy
    remove_file(path, manage_as)
  end

  def create
    # create the file
    if !resource[:directory]
      runuser(['-u', resource[:manage_as], '--', 'touch', resource[:path]])
    else
      runuser(['-u', resource[:manage_as], '--', 'mkdir', resource[:path]])
    end

    # set file attributes
    runuser(['-u', resource[:manage_as], '--', 'chown', resource[:owner], resource[:path]]) unless owner.nil?
    unless resource[:group].nil?
      runuser(['-u', resource[:manage_as], '--', 'chown', ":#{resource[:group]}", resource[:path]])
    end
    runuser(['-u', resource[:manage_as], '--', 'chmod', resource[:mode], resource[:path]]) unless resource[:mode].nil?
  end

  def directory
    file_exists(resource[:path], resource[:manage_as], true) ? 'true' : 'false'
  end

  # this will fail because changing between a directory and a file is destructive
  def directory=(_)
    raise 'Cannot switch between directory and file'
  end

  def owner
    runuser(['-u', resource[:manage_as], '--', 'stat', '--printf=%U', resource[:path]])
  rescue Puppet::ExecutionFailure
    nil
  end

  def owner=(value)
    runuser(['-u', resource[:manage_as], '--', 'chown', value, resource[:path]])
  end

  def group
    runuser(['-u', resource[:manage_as], '--', 'stat', '--printf=%G', resource[:path]])
  rescue Puppet::ExecutionFailure
    nil
  end

  def group=(value)
    runuser(['-u', resource[:manage_as], '--', 'chown', ":#{value}", resource[:path]])
  end

  def mode
    runuser(['-u', resource[:manage_as], '--', 'stat', '--printf=0%a', resource[:path]])
  rescue Puppet::ExecutionFailure
    nil
  end

  def mode=(value)
    runuser(['-u', resource[:manage_as], '--', 'chmod', value, resource[:path]])
  end
end
