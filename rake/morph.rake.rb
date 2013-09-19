require 'rake/clean'

MORPH_SRC = "#{SRC_DIR}/morphology.fst"
MORPH_OBJ_SRC = "#{OBJ_DIR}/morphology.fst"
MORPH_OBJ = "#{OBJ_DIR}/morphology.a"
MORPH_ATT = "#{OBJ_DIR}/morphology.att"
MORPH_ATS = "#{OBJ_DIR}/morphology.ats"
MORPH_ATE = "#{OBJ_DIR}/morphology.ate"

CLOBBER.include(MORPH_OBJ)
CLOBBER.include(MORPH_ATT)
CLOBBER.include(MORPH_ATS)
CLOBBER.include(MORPH_ATE)

namespace :morph do

  file MORPH_OBJ => [OBJ_DIR, "stems:default", "endings:default", "acceptor:default", "derived_types:default", MORPH_OBJ_SRC] 
  
  file MORPH_OBJ_SRC => MORPH_SRC do |t|
    FileUtils.cp MORPH_SRC, MORPH_OBJ_SRC
  end


  desc "Build the final AT&T format FST required for Parsley."
  task :default => [MORPH_OBJ, MORPH_ATT, MORPH_ATS]

end
