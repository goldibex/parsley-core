require 'nokogiri'
require_relative 'helpers/morpheus_xml_reader.rb'

namespace :stems do
  STEMS_DIR = "#{SRC_DIR}/stems"

  NOUN_STEM_XML = "#{STEMS_DIR}/morpheus_nouns.xml"
  VERB_STEM_XML = "#{STEMS_DIR}/morpheus_verbs.xml"
  NOUN_STEM_LEX = "#{STEMS_DIR}/nouns.lex"
  VERB_STEM_LEX = "#{STEMS_DIR}/verbs.lex"
  STEMS_SRC = "#{OBJ_DIR}/stems.fst"
  STEMS_OBJ = "#{OBJ_DIR}/stems.a"

  CLEAN.include(NOUN_STEM_LEX)
  CLEAN.include(VERB_STEM_LEX)
  CLOBBER.include(STEMS_SRC)
  CLOBBER.include(STEMS_OBJ)
 
  task :stems => :stems_lex do
    sh "fst-compiler #{STEMS_SRC} #{STEMS_OBJ}"
  end
  
  multitask :stems_lex => [NOUN_STEM_LEX, VERB_STEM_LEX] do
    out = File.open(STEMS_SRC, "w")
    out.puts "\"#{NOUN_STEM_LEX}\" | \"#{VERB_STEM_LEX}\""
    out.close
  end

  task NOUN_STEM_LEX do
    parser = Nokogiri::XML::SAX::Parser.new(MorpheusXMLReader.new NOUN_STEM_LEX)
    parser.parse(File.open(NOUN_STEM_XML))
  end

  task VERB_STEM_LEX do
    parser = Nokogiri::XML::SAX::Parser.new(MorpheusXMLReader.new VERB_STEM_LEX)
    parser.parse(File.open(VERB_STEM_XML))
  end

  desc "Create the stem vocabulary FST."
  task :default => :stems
end
