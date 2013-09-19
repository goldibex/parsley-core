require 'yaml'
require 'json'

require_relative "helpers/yaml_to_plist.rake"

GRAMMAR_JSON = "#{OBJ_DIR}/grammar.json"
GRAMMAR_PLIST = "#{OBJ_DIR}/grammar.plist"

CLOBBER.include(GRAMMAR_JSON)
CLOBBER.include(GRAMMAR_PLIST)

namespace :grammar do
  file GRAMMAR_JSON => [OBJ_DIR] do
    File.open(GRAMMAR_JSON, "w")
    .print(YAML.load_file("definition.yaml").to_json)
  end

  file GRAMMAR_PLIST => [OBJ_DIR] do
    File.open(GRAMMAR_PLIST, "w")
    .print PlistWriter.new(YAML.load_file("definition.yaml")).to_s
  end

  desc "Build the plist language description."
  task :plist => GRAMMAR_PLIST

  desc "Build the JSON language description."
  task :json => GRAMMAR_JSON
end
