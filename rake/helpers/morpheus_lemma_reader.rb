require 'nokogiri'
require 'yaml'

class MorpheusLemmaReader < Nokogiri::XML::SAX::Document
  def initialize(out_filename)
    @acc = ""
    @out_filename = out_filename
    if File.exists? @out_filename
      File.unlink @out_filename
    end
    @parse_info = YAML.load_file("definition.yaml")
    @morph_lookup = @parse_info["inflection_lookup"]
  end
  
  def start_document
    @out = File.open(@out_filename, "a")
  end
  
  def start_element(name, attrs=[])
    # clear the text accumulator
    @acc = ""

    case name
    when "le"
      @stem = nil
      @lemma = nil
      @itype = nil
      @whole_word = false
      @morph_choices = nil
    end
  end

  def characters(str_data)
    @acc += str_data
  end

  def end_element(name)
    case name
    when "le"
      @lemma = @acc
    when "form"
      @whole_word = true
      @stem = @acc
    when "stem"
      @whole_word = false
      @stem = @acc
    when "morph"
      # parse morphological data
      # convert these to what SFST expects
      # i.e., masc fem -> 2 entries, 1 with masc and 1 with fem
      # nom/voc/acc -> 3 entries
      # masc fem nom/voc/acc -> 6 entries
      morph_data = {}
      @acc.split(/[\s\/]+/).each do |morph_unit|
        morph_type = @morph_lookup[morph_unit]
        if morph_data[morph_type] == nil
          morph_data[morph_type] = [morph_unit]
        else
          morph_data[morph_type].push(morph_unit)
        end
      end
      morph_bits = morph_data.values 
      @morph_choices = morph_bits.shift.product(*morph_bits)
    when "itype"
      @itype = @acc
    when "no", "wd", "aj", "vs", "de", "vb"
      # write entry to disk
      # align the lemma and stem
      # so, mal:malus -> malu:<>s:<>     
      if @morph_choices.nil?
        @morph_choices = [[]]
      else
        @morph_choices.map! do |item|
          item.map { |bit| bit.start_with?("<") ? bit : "<#{bit}>" }
        end
      end
      @morph_choices.each do |morph_choice|
        out_final = ""
        split_stem = @stem.gsub(/\s+/, "").split(//) + morph_choice + ["<#{@itype}>"]
        split_lemma = @lemma.gsub(/\s+/, "").split(//)
#        puts "#{split_stem} __ #{split_lemma}"
        max = split_stem.length > split_lemma.length ? split_stem.length : split_lemma.length
        max.times do |i|
          if ((i < split_lemma.length) && (i < split_stem.length))
            out_final << if split_lemma[i] == split_stem[i] then split_lemma[i] else "#{split_lemma[i]}:#{split_stem[i]}" end
          elsif (i < split_stem.length)
            out_final << "<>:#{split_stem[i]}"
          elsif (i < split_lemma.length)
            out_final << "#{split_lemma[i]}:<>"
          end        
        end
        @out.puts out_final
      end

    when "entry"
    when "entries"
    else
      raise "DON'T KNOW #{name}"
    end
  end

  def end_document
    @out.close
  end
end
