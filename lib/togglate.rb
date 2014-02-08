require "togglate/version"
require "togglate/block_wrapper"
require "togglate/cli"

module Togglate
  def self.create(file, opts={})
    text = File.read(file)
    wrapped = BlockWrapper.new(text, opts).run
    if toggle_code
      code = toggle_code(target, opts)
      [wrapped, code].join("\n")
    else
      wrapped
    end
  rescue => e
    STDERR.puts "something go wrong. #{e}"
    exit
  end

  def self.toggle_code(target, show_text, hide_text)
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
end
