$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'togglate'

class String
  def ~
    margin = scan(/^ +/).map(&:size).min
    gsub(/^ {#{margin}}/, '')
  end
end
