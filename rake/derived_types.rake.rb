namespace :derived_types do
  DERIVS_DIR = "#{SRC_DIR}/derivs"
  DERIVS_OBJ = "#{OBJ_DIR}/derivs.a"
  DERIVS_SRC = "#{OBJ_DIR}/derivs.fst"

  DERIVS_EACH_FST = FileList["#{DERIVS_DIR}/*.fst"]
  DERIVS_EACH_OBJ = DERIVS_EACH_FST.ext("a")

  CLEAN.include(DERIVS_EACH_OBJ)
  CLOBBER.include(DERIVS_OBJ)
  CLOBBER.include(DERIVS_SRC)

  rule '.a' => '.fst' do |t|
    sh "fst-compiler #{t.source} #{t.name}"
  end

  file DERIVS_OBJ => DERIVS_SRC

  file DERIVS_SRC => DERIVS_EACH_OBJ do
    out = File.open(DERIVS_SRC, "w")
    out.print "("
    first_line = true
    DERIVS_EACH_OBJ.each do |fst|
      if first_line then first_line = false else out.print "|\\\n" end
      fst_name = File.basename(fst, ".*")
      out.print "\"<#{fst}>\""
    end
    out.print ")\n"
    out.close
  end

  desc "Build the derived types FST."
  task :default => DERIVS_OBJ

end
