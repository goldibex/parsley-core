require 'rake/clean'

SRC_DIR = "src"
OBJ_DIR = "out"

Dir.glob('rake/*.rake.rb').each { |r| 
  require "#{File.dirname(__FILE__)}/#{r}"
}
