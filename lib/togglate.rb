require "mymemory"

require "togglate/version"
require "togglate/core_ext"
require "togglate/block_wrapper"
require "togglate/cli"

module Togglate
  def self.create(file, opts={})
    text = File.read(file)
    wrapped = BlockWrapper.new(text, opts).run
    if opts[:embed_code]
      code = append_code(opts[:method], opts)
      "#{wrapped}\n#{code}"
    else
      wrapped
    end
  rescue => e
    STDERR.puts "something go wrong. #{e}"
    exit
  end

  def self.commentout(file)
    text = File.read(file)
    comment_key = 'original'

    comments = []
    comment_re = /\n?^<!--#{comment_key}\n(.*?)^-->\n?/m
    remains = text.gsub(comment_re) { |m| comments << $1; '' }
    return comments*"\n", remains
  rescue => e
    STDERR.puts "something go wrong. #{e}"
    exit
  end

  def self.append_code(method, opts)
    send("#{method}_code", opts)
  end

  def self.toggle_code(name:'original', toggle_link_text:["*", "hide"], **opts)
    <<-"CODE"
<script src="http://code.jquery.com/jquery-1.11.0.min.js"></script>
<script>
$(function() {
  $("*").contents().filter(function() {
    return this.nodeType==8 && this.nodeValue.match(/^#{name}/);
  }).each(function(i, e) {
    var tooltips = e.nodeValue.replace(/^#{name} *[\\n\\r]|[\\n\\r]$/g, '');
    var link = "<span><a href='#' onclick='javascript:return false;' class='toggleLink'>" + "#{toggle_link_text[0]}" + "</a></span>";
    $(this).prev().append(link);
    $(this).prev().after("<pre style='display:none'>"+ tooltips + "</pre>");
  });

  $('.toggleLink').click(
    function() {
      if ($(this).text()=="#{toggle_link_text[0]}") {
       $(this).parent().parent().next('pre').slideDown(200);
       $(this).text("#{toggle_link_text[1]}");
      } else {
        $(this).parent().parent().next('pre').slideUp(200);
        $(this).text("#{toggle_link_text[0]}");
      };
    });
});
</script>
CODE
  end

  def self.hover_code(name:'original', **opts)
    <<-"CODE"
<script src="http://code.jquery.com/jquery-1.11.0.min.js"></script>
<script>
$(function() {
  $("*").contents().filter(function() {
    return this.nodeType==8 && this.nodeValue.match(/^#{name}/);
  }).each(function(i, e) {
    var tooltips = e.nodeValue.replace(/^#{name}\s*[\\n\\r]|[\\n\\r]$/g, '');
    $(this).prev().attr('title', tooltips);
  });
});
</script>
CODE
  end
end
