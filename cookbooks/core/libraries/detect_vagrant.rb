module DetectVagrant
  def vagrant_exists?
    File.exist?('/vagrant/.vagrant')
  end

  def emit_marker(sym)
    rightscale_marker sym unless vagrant_exists?

  end
end