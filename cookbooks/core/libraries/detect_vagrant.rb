module DetectVagrant
  def vagrant_exists?
    File.exist?('/vagrant/.vagrant')
  end

  def esx?
    File.exist?('/opscode')
  end

  def emit_marker(sym)
    return if vagrant_exists?
    return if esx?

    rightscale_marker sym
  end
end