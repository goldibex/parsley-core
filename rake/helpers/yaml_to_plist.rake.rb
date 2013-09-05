#!/usr/bin/env ruby
# encoding: UTF-8
require 'yaml'
require 'rexml/document'
 
class PlistWriter
  PLIST_STUB_DOC = %q[
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0"></plist>]
 
  def initialize(root_object)
    @document     = REXML::Document.new PLIST_STUB_DOC
    @current_node = @document.root
    process(root_object)
  end
 
  def build_element(name, text = nil)
    @current_node.add_element(name.to_s).tap do |new_node|
      new_node.add_text(text.to_s.dup) unless text.nil?
      next unless block_given?
      _current_node = @current_node
      @current_node = new_node
      yield
      @current_node = _current_node
    end
  end
 
  def process(object)
    case object
    when Hash           then build_element :dict   do object.each { |k, v| build_element(:key, k); process(v) } end
    when Array          then build_element :array  do object.each { |e| process(e) }                            end
    when String         then build_element :string , object
    when Integer        then build_element :integer, object
    when Float          then build_element :real   , object
    when Date           then build_element :date   , object.to_time(:utc).iso8601
    when Time, DateTime then build_element :date   , object.to_time.utc.iso8601
    when FalseClass     then build_element :false
    when TrueClass      then build_element :true
    else raise "Unexpected object of class #{object.class.name}"
    end
  end
 
  def to_s
    "".tap { |s| f = REXML::Formatters::Pretty.new; f.compact = true; f.write(@document, s) }
  end
end
