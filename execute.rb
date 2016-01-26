STDOUT.sync = true

require "tilt"
require "logger"
require "faraday"
require "sanitize"
require_relative "./audit.rb"

logger = Logger.new(STDOUT)

def result_hash(result)
  cve = if result.advisory.cve
          "CVE-#{result.advisory.cve}"
        elsif result.advisory.osvdb
          "OSVDB-#{result.advisory.osvdb}"
        end

  solution = unless result.advisory.patched_versions.empty?
               "upgrade to #{result.advisory.patched_versions.join(",")}"
             else
               "remove or disable this gem until a patch is available!"
             end

  { 
    name: result.gem.name,
    version: result.gem.version.to_s,
    advisory:  cve,
    criticality: result.advisory.criticality,
    url: result.advisory.url,
    description: result.advisory.description,
    solution: solution
  }
end

def truncate(string, max)
  string.length > max ? "#{string[0...max]}..." : string
end

results = scan.map do |result|
  result_hash(result)
end

if results.empty?
  logger.info "No vulnerabilities found"
  exit(0)
end

logger.info "Security vulnerabilities found"

conn = Faraday.new(:url => ENV.fetch("APP_URL")) do |config|
  config.adapter Faraday.default_adapter
end

logger.info ENV.fetch("APP_URL")
logger.info conn.inspect

results.group_by { |x| x[:name] }.each do |key, issues|
  t = Tilt::ERBTemplate.new(Dir.pwd + 'app/template.txt.erb')
  body = t.render(self, {key: key, issues: issues})
  logger.info body
  res = conn.post do |req|
    req.url '/discoveries'
    req.headers['Content-Type'] = 'application/json'
    req.headers['Authorization'] = "Basic #{ENV.fetch("ACCESS_TOKEN")}"
    req.body = {
      title: key,
      task_id: ENV.fetch("TASK_ID"),
      kind: :security,
      identifier: issues.first[:advisory],
      code_changed: false,
      priority: (issues.map { |i| i[:criticality] }.include?(:high) ? :high : issues.first[:criticality]) || :unknown,
      message: body
    }.to_json
  end
  logger.info res.inspect
end
