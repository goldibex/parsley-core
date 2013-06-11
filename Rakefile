require 'rake/clean'

SRC_DIR = "src"
OBJ_DIR = "out"

Dir.glob('rake/*.rake.rb').each { |r| 
  require "#{File.dirname(__FILE__)}/#{r}"
}

defaults = []
Rake.application.tasks.each do |t|
  if t.name.match(/:default$/)
    defaults << t
  end
end

desc "Build the final morphology analysis FST."
multitask :morph => defaults do
  sh "fst-compiler src/morphology.fst out/morphology.a"  
end

directory "out"
task :default => :morph
