require 'rake/clean'

MORPH_SRC = "#{SRC_DIR}/morphology.fst"
MORPH_OBJ = "#{OBJ_DIR}/morphology.a"
MORPH_ATT = "#{OBJ_DIR}/morphology.att"

CLOBBER.include(MORPH_OBJ)
CLOBBER.include(MORPH_ATT)

defaults = [OBJ_DIR]

namespace :morph do

  desc "Build the final morphology analysis FST."
  task :morph => MORPH_OBJ

  file MORPH_OBJ => [OBJ_DIR, "stems:default", "endings:default", "acceptor:default", "derived_types:default"] do
    sh "fst-compiler #{MORPH_SRC} #{MORPH_OBJ}"
  end

  desc "Build the final AT&T format FST required for Parsley."
  task :att => MORPH_ATT

  file MORPH_ATT => MORPH_OBJ do
    sh "fst-print #{MORPH_OBJ} > #{MORPH_ATT}"
  end

end
