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

  def write_file(owner, content, path)
    content = content.gsub(/\\/, '\\\\').gsub(/"/, '\\"')
    runuser(['-l', owner, '-c', "echo -n '#{content}' > #{path}"])
  end

  def exists?
    resource_exists(resource[:path], resource[:owner])
  end

  def destroy
    runuser(['-u', owner, '--', 'rm', '-rf', path])
  end

  def create
    # create the file
    case resource[:resource_type]
    when :file
      runuser(['-u', resource[:owner], '--', 'touch', resource[:path]])
    when :directory
      runuser(['-u', resource[:owner], '--', 'mkdir', resource[:path]])
    end

    group = runuser(['-u', resource[:owner], '--', 'stat', '--printf=%G', resource[:path]])
    mode = runuser(['-u', resource[:owner], '--', 'stat', '--printf=0%a', resource[:path]])

    # set file attributes
    if !resource[:group].nil? && group != resource[:group]
      runuser(['-u', resource[:owner], '--', 'chown', ":#{resource[:group]}", resource[:path]])
    end
    if !resource[:mode].nil? && mode != resource[:mode]
      runuser(['-u', resource[:owner], '--', 'chmod', resource[:mode], resource[:path]])
    end
    write_file(resource[:owner], resource[:content], resource[:path]) unless resource[:content].nil?
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

  def content
    runuser(['-u', resource[:owner], '--', 'cat', resource[:path]])
  rescue Puppet::ExecutionFailure
    nil
  end

  def content=(value)
    write_file(resource[:owner], value, resource[:path])
  end
end
