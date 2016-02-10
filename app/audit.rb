lib_dir = File.expand_path(File.join(File.dirname(__FILE__),'bundler-audit','lib'))
$LOAD_PATH << lib_dir unless $LOAD_PATH.include?(lib_dir)

require 'ostruct'
require 'json'

require_relative './bundler-audit/lib/bundler/audit/advisory'
require_relative './bundler-audit/lib/bundler/audit/scanner'
require_relative './bundler-audit/lib/bundler/audit/version'

def scan
  results = []
  Bundler::Audit::Scanner.new(File.expand_path "../target").scan(:ignore => []) do |result|
    if result.class == Bundler::Audit::Scanner::UnpatchedGem
      results << result
    end
  end
  results
end
