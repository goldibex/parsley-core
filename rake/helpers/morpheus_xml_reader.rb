require 'nokogiri'
require 'yaml'

class MorpheusXMLReader < Nokogiri::XML::SAX::Document
  def initialize(out_filename)
    @acc = ""
    @out_filename = out_filename
    @parse_info = YAML.load_file("definition.yaml")
    @morph_lookup = @parse_info["inflection_lookup"]
  end
  
  def start_document
    @out = File.open(@out_filename, "w")
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
    when "no", "wd", "aj", "vb", "vs", "de"
      # write entry to disk
      # align the lemma and stem
      # so, mal:malus -> malu:<>s:<>
      stem_chars = @stem.gsub(/\s+/, "").split(//)
      lemma_chars = @lemma.gsub(/\s+/, "").split(//)
      if stem_chars.length > lemma_chars.length 
        longer_chars, shorter_chars = stem_chars, lemma_chars
      else
        longer_chars, shorter_chars = lemma_chars, stem_chars
      end
      zipped_chars = longer_chars.zip(shorter_chars)
      stem_text = zipped_chars.map do |z|
        a = z[0] || "<>"
        b = z[1] || "<>"
        if a == b then a else "#{a}:#{b}" end 
      end
      
#      ww = if @whole_word then "<whole_word>" else "" end
      ww = ""

      if @morph_choices.nil?
        @out.puts "#{stem_text.join}<#{@itype}>#{ww}"
      else
        @morph_choices.each do |morph_choice|
          morph_data = "<#{morph_choice.join "><"}>"
          @out.puts "#{stem_text.join}#{morph_data}<#{@itype}>#{ww}"
        end
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
