namespace :endings do
  ENDINGS_DIR = "#{SRC_DIR}/endings"
  ENDINGS_OBJ = "#{OBJ_DIR}/endings.a"
  ENDINGS_SRC = "#{OBJ_DIR}/endings.fst"
  ENDINGS_EACH_ASC = FileList["#{ENDINGS_DIR}/*.asc"]
  ENDINGS_EACH_FST = ENDINGS_EACH_ASC.ext("fst")
  ENDINGS_EACH_OBJ = ENDINGS_EACH_ASC.ext("a")

  CLEAN.include(ENDINGS_EACH_OBJ)
  CLEAN.include(ENDINGS_EACH_FST)
  CLOBBER.include(ENDINGS_OBJ)
  CLOBBER.include(ENDINGS_SRC)

  rule '.a' => '.fst' do |t|
    sh "fst-compiler #{t.source} #{t.name}"
  end

  rule '.fst' => '.asc' do |t|
    out = File.open(t.name, "w")
    out.print "("
    first_line = true
    File.open(t.source).each_line do |source_line|
      bits = source_line.split(/\s+/)
      ending = bits.shift
      if first_line then first_line = false else out.print "|\\\n" end
      out.print ending.gsub(/^\*/, "").gsub(/([_+*]+)/) { |s| "\\#{s}"}
      stemtype = bits.shift
      parsedata = bits.map { |bit| bit.split(/\//) }
      parsedata.each do |parsedatum|
        parsedatum.map! { |x| "<#{x}>" }
        if parsedatum.length > 1
          out.print "[#{parsedatum.join}]"
        else
          out.print parsedatum.join
        end
      end
  #    outparses = parsedata.shift.product(*parsedata)
  #    outparses.each do |outparse|
  #      outparse.map!{ |x| "<#{x}>" }
  #      out.puts "#{ending}#{outparse.join}"
  #    end
    end
    out.print ")\n"
    out.close
  end

  file ENDINGS_SRC => ENDINGS_EACH_OBJ do
    out = File.open(ENDINGS_SRC, "w")
    out.print "("
    first_line = true
    ENDINGS_EACH_OBJ.each do |fst|
      if first_line then first_line = false else out.print "|\\\n" end
      fst_name = File.basename(fst, ".*")
      out.print("\"<#{fst}>\" <#{fst_name}>")
    end
    out.print ")\n"
    out.close
  end

  file ENDINGS_OBJ => ENDINGS_SRC do
    sh "fst-compiler #{ENDINGS_SRC} #{ENDINGS_OBJ}"
  end

  desc "Build all endings sources to FST."
  task :default => ENDINGS_OBJ
end
