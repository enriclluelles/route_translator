require 'gibberish/localize'
require 'gibberish/string_ext'

String.send :include, Gibberish::StringExt

module Gibberish
  extend Localize
end
