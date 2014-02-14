require "togglate/version"
require "togglate/block_wrapper"
require "togglate/cli"

module Togglate
  def self.create(file, opts={})
    text = File.read(file)
    if [:hover, :comment].include?(opts[:method].intern)
      opts.update(wrapper:%W([translation\ here]\n<!--original -->))
    end
    wrapped = BlockWrapper.new(text, opts).run
    case opts[:method].intern
    when :toggle
      code = toggle_code(opts)
      [wrapped, code].join("\n\n")
    when :hover, :comment
      code = hover_code(opts)
      [wrapped, code].join("\n\n")
    else
      wrapped
    end
  rescue => e
    STDERR.puts "something go wrong. #{e}"
    exit
  end

  def self.toggle_code(target:%($("pre[lang='original']")), show_text:"*", hide_text:"hide", **opts)
    <<-"CODE"
<script src="http://code.jquery.com/jquery-1.11.0.min.js"></script>
<script>
function createToggleLinks(target, showText, hideText) {
var link = "<span><a href='#' onclick='javascript:return false;' class='toggleLink'>" + showText + "</a></span>";
target.hide().prev().append(link);
$('.toggleLink').click(
  function() {
    if ($(this).text()==showText) {
     $(this).parent().parent().next(target).slideDown(200);
     $(this).text(hideText);
    } else {
      $(this).parent().parent().next(target).slideUp(200);
      $(this).text(showText);
    };
  });
}
var element = #{target};
createToggleLinks(element, "#{show_text}", "#{hide_text}");
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
    var tooltips = e.nodeValue.replace(/^#{target}\s*/, '');
    $(this).prev().attr('title', tooltips);
  });
});
</script>
CODE
  end
end
