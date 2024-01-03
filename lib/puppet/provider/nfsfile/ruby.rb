# frozen_string_literal: true

Puppet::Type.type(:nfsfile).provide(:ruby) do
  commands runuser: '/usr/sbin/runuser'

  def file_exists(path, owner)
    runuser(['-u', owner, '--', 'test', '-f', path])
    true
  rescue Puppet::ExecutionFailure
    false
  end

  def dir_exists(path, owner)
    runuser(['-u', owner, '--', 'test', '-d', path])
    true
  rescue Puppet::ExecutionFailure
    false
  end

  def resource_exists(path, owner)
    runuser(['-u', owner, '--', 'test', '-e', path])
    true
  rescue Puppet::ExecutionFailure
    false
  end

  def remove_file(path, owner)
    runuser(['-u', owner, '--', 'rm', '-rf', path])
  rescue Puppet::ExecutionFailure
    nil
  end

  def exists?
    resource_exists(resource[:path], resource[:owner])
  end

  def destroy
    remove_file(path, owner)
  end

  def create
    # create the file
    case resource[:resource_type]
    when :file
      runuser(['-u', resource[:owner], '--', 'touch', resource[:path]])
    when :directory
      runuser(['-u', resource[:owner], '--', 'mkdir', resource[:path]])
    end

    # set file attributes
    unless resource[:group].nil?
      runuser(['-u', resource[:owner], '--', 'chown', ":#{resource[:group]}", resource[:path]])
    end
    runuser(['-u', resource[:owner], '--', 'chmod', resource[:mode], resource[:path]]) unless resource[:mode].nil?
  end

  def resource_type
    return :file if file_exists(resource[:path], resource[:owner])

    :directory if dir_exists(resource[:path], resource[:owner])
  end

  def resource_type=(_)
    raise "Resource #{resource[:path]} already exists."
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
