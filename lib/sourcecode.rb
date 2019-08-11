#
# =tcl=
# tcl source code
# ...
# ==
# =sh=
# sh source code
# ...
# ==
class SourceCodeFilter < Nanoc::Filter
  identifier :sourcecode

  def run(content, params={})
	content.gsub(/^=([a-z]+)=$/, '<pre class="sh_\1">').gsub(/^==$/, '</pre>')
  end
end
