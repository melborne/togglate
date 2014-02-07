require "togglate/version"
require "togglate/cli"

module Togglate
  class BlockWrapper
    def initialize(text,
                   space_re:/^\s*$/,
                   chunk_exceptions:[/^```/],
                   wrapper:%w(```original ```),
                   wrap_exceptions:[/^```/, /^\s{4}/])
      @text = text
      @space_re = space_re
      @chunk_exceptions = chunk_exceptions
      @wrapper = wrapper
      @wrap_exceptions = wrap_exceptions
    end

    def run
      wrap_with chunk_by_space
    end

    private
    def chunk_by_space
      in_block = false
      @text.each_line.chunk do |line|
        in_block = !in_block if @chunk_exceptions.any? { |ex| line.match ex }
        !line.match(@space_re).nil? && !in_block
      end
    end

    def wrap_with(chunks)
      chunks.inject([]) do |m, (is_space, lines)|
        if is_space || @wrap_exceptions.any? { |ex| lines[0].match ex }
          m.push *lines
        else
          m.push @wrapper[0], "\n", *lines, @wrapper[1], "\n"
        end
      end.join
    end
  end

  class << self
    def create(file,
               wrapper:%w(```original ```),
               toggle_code:true,
               target:%($("pre[lang='original']")),
               show_text:"*",
               hide_text:"hide")
      text = File.read(file)
      wrapped = BlockWrapper.new(text, wrapper:wrapper).run
      if toggle_code
        code = toggle_code(target, show_text, hide_text)
        [wrapped, code].join("\n")
      else
        wrapped
      end
    rescue => e
      STDERR.puts "something go wrong. #{e}"
      exit
    end

    def toggle_code(target, show_text, hide_text)
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
createToggleLinks(element, #{show_text}, #{hide_text});
</script>
CODE
    end
  end
end
