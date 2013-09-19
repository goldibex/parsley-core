rule ".a" => ".fst" do |t|
  sh "fst-compiler #{t.source} #{t.name}"
end

rule ".att" => ".a" do |t|
  sh "fst-print #{t.source} > #{t.name}"
end

rule ".ats" => ".att" do |t|
  symbols = Hash.new
  symbol_id = 0
  ats = File.open(t.name, "w")
  ate = File.open(File.join(File.dirname(t.name), File.basename(t.name, ".*")) + ".ate", "w")
  IO.foreach(File.open(t.source, "r")) do |l|
    if /^(\d+)\s+(\d+)\s+(\S+)\s+(\S+)\s*$/.match(l) # symbol line
      if !symbols[$3]
        symbols[$3] = symbol_id
        symbol_id += 1
        ats.puts $3
      end
      if !symbols[$4]
        symbols[$4] = symbol_id
        symbol_id += 1
        ats.puts $4
      end
      ate.puts "#{$1} #{$2} #{symbols[$3]} #{symbols[$4]}"
    elsif /^(\d+)\s*$/.match(l) # terminator
      ate.puts "#{$1}"
    end
  end
end


namespace :acceptor do
  ACCEPTOR_DIR = "#{SRC_DIR}/acceptor"
  ACCEPTOR_OBJ = "#{OBJ_DIR}/acceptor.a"
  ACCEPTOR_SRC = "#{OBJ_DIR}/acceptor.fst"
  ACCEPTOR_EACH_SRC = FileList["#{ACCEPTOR_DIR}/*.fst"]
  ACCEPTOR_EACH_OBJ = ACCEPTOR_EACH_SRC.ext("a")

  CLEAN.include(ACCEPTOR_SRC)
  CLEAN.include(ACCEPTOR_EACH_OBJ)
  CLOBBER.include(ACCEPTOR_OBJ)

  file ACCEPTOR_SRC => ACCEPTOR_EACH_OBJ do
    out = File.open(ACCEPTOR_SRC, "w")
    first_line = true
    ACCEPTOR_EACH_OBJ.each do |obj|
      puts obj
      if first_line then first_line = false else out.print " |\\\n" end
      out.print("\"<#{obj}>\"")
    end
    out.close
  end

  file ACCEPTOR_OBJ => ACCEPTOR_SRC do
    sh "fst-compiler #{ACCEPTOR_SRC} #{ACCEPTOR_OBJ}"
  end

  desc "Build the acceptor (grammar) FST."
  task :default => ACCEPTOR_OBJ

end
