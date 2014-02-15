require "togglate/version"
require "togglate/block_wrapper"
require "togglate/cli"

module Togglate
  def self.create(file, opts={})
    text = File.read(file)
    wrapped = BlockWrapper.new(text, opts).run
    if opts[:code]
      code = append_code(opts[:method], opts)
      "#{wrapped}\n#{code}"
    else
      wrapped
    end
  rescue => e
    STDERR.puts "something go wrong. #{e}"
    exit
  end

  def self.append_code(method, opts)
    send("#{method}_code", opts)
  end

  def self.toggle_code(show_text:"*", hide_text:"hide", **opts)
    <<-"CODE"
<script src="http://code.jquery.com/jquery-1.11.0.min.js"></script>
<script>
$(function(showText, hideText) {
  $("*").contents().filter(function() {
    return this.nodeType==8 && this.nodeValue.match(/^original/);
  }).each(function(i, e) {
    var tooltips = e.nodeValue.replace(/^original *[\n\r]|[\n\r]$/g, '');
    var link = "<span><a href='#' onclick='javascript:return false;' class='toggleLink'>" + "*" + "</a></span>";
    $(this).prev().append(link);
    $(this).prev().after("<pre>"+ tooltips + "</pre>");
  });

  $('.toggleLink').click(
    function() {
      if ($(this).text()==showText) {
       $(this).parent().parent().next('pre').slideDown(200);
       $(this).text(hideText);
      } else {
        $(this).parent().parent().next('pre').slideUp(200);
        $(this).text(showText);
      };
    });
});
</script>
CODE
  end

  def self.hover_code(target:'original', **opts)
    <<-"CODE"
<script src="http://code.jquery.com/jquery-1.11.0.min.js"></script>
<script>
$(function() {
  $("*").contents().filter(function() {
    return this.nodeType==8 && this.nodeValue.match(/^#{target}/);
  }).each(function(i, e) {
    var tooltips = e.nodeValue.replace(/^#{target}\s*[\\n\\r]|[\\n\\r]$/g, '');
    $(this).prev().attr('title', tooltips);
  });
});
</script>
CODE
  end
end
