# frozen_string_literal: true
Puppet::Type.type(:nfsfile).provide(:ruby) do
  commands runuser: '/usr/sbin/runuser'

  def file_exists(path, owner, is_directory)
    if !is_directory
      begin
        runuser(['-u', owner, '--', 'test', '-f', path])
      rescue Puppet::ExecutionFailure
        return false
      end
    else
      begin
        runuser(['-u', owner, '--', 'test', '-d', path])
      rescue Puppet::ExecutionFailure
        return false
      end
    end
    true
  end

  def remove_file(path, owner)
    runuser(['-u', owner, '--', 'rm', '-rf', path])
  rescue Puppet::ExecutionFailure
    nil
  end

  def exists?
    file_exists(resource[:path], resource[:owner], resource[:directory])
  end

  def destroy
    remove_file(path, owner)
  end

  def create
    # create the file
    if !resource[:directory]
      runuser(['-u', resource[:owner], '--', 'touch', resource[:path]])
    else
      runuser(['-u', resource[:owner], '--', 'mkdir', resource[:path]])
    end

    # set file attributes
    unless resource[:group].nil?
      runuser(['-u', resource[:owner], '--', 'chown', ":#{resource[:group]}", resource[:path]])
    end
    runuser(['-u', resource[:owner], '--', 'chmod', resource[:mode], resource[:path]]) unless resource[:mode].nil?
  end

  def directory
    file_exists(resource[:path], resource[:owner], true) ? 'true' : 'false'
  end

  # this will fail because changing between a directory and a file is destructive
  def directory=(_)
    raise 'Cannot switch between directory and file'
  end

  def group
    runuser(['-u', resource[:owner], '--', 'stat', '--printf=%G', resource[:path]])
  rescue Puppet::ExecutionFailure
    nil
  end

  def group=(value)
    runuser(['-u', resource[:owner], '--', 'chown', ":#{value}", resource[:path]])
  end

  def mode
    runuser(['-u', resource[:owner], '--', 'stat', '--printf=0%a', resource[:path]])
  rescue Puppet::ExecutionFailure
    nil
  end

  def mode=(value)
    runuser(['-u', resource[:owner], '--', 'chmod', value, resource[:path]])
  end
end
