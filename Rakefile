require 'rubygems'
require 'rake/gempackagetask'
require 'rubygems/specification'
require 'date'
require 'spec/rake/spectask'

GEM = "shipping_consumer"
GEM_VERSION = "0.0.1"
AUTHOR = "Your Name"
EMAIL = "Your Email"
HOMEPAGE = "http://example.com"
SUMMARY = "A gem that provides..."

spec = Gem::Specification.new do |s|
  s.name = GEM
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "LICENSE", 'TODO']
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  
  # Uncomment this to add a dependency
  # s.add_dependency "foo"
  
  s.require_path = 'lib'
  s.autorequire = GEM
  s.files = %w(LICENSE README Rakefile TODO) + Dir.glob("{lib,spec}/**/*")
end

task :default => :spec

desc "Run specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = %w(-fs --color)
end


Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "install the gem locally"
task :install => [:package] do
  sh %{sudo gem install pkg/#{GEM}-#{GEM_VERSION}}
end

desc "create a gemspec file"
task :make_spec do
  File.open("#{GEM}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end

desc "update country codes as per ISO standard"
task :update_country_codes do
  require 'net/http'
  require 'active_support'
  require 'yaml'
  resp = Net::HTTP.get(URI.parse("http://www.iso.org/iso/list-en1-semic-2.txt"))
  yaml = "# " + resp.gsub(/(.*?);/) { $1.titleize + ": "}
  File.open("config/country_codes.yml","w") {|file| file << yaml}
end

desc "generates unique ids for the specified mail classes from the specified file.
      Usage: rake generate_unique_ids CARRIER=USPS"
task "generate_service_ids" do
  require 'active_support'
  require 'yaml'
  require 'lib/shipping_consumer'
  
  class Symbol
    def <=>(other)
      self.to_s <=> other.to_s
    end
  end
  
  class Hash
    # Replacing the to_yaml function so it'll serialize hashes sorted (by their keys)
    #
    # Original function is in /usr/lib/ruby/1.8/yaml/rubytypes.rb
    def to_yaml( opts = {} )
      YAML::quick_emit( object_id, opts ) do |out|
        out.map( taguri, to_yaml_style ) do |map|
          sort.each do |k, v|   # <-- here's my addition (the 'sort')
            map.add( k, v )
          end
        end
      end
    end
  end
  
  carrier = ENV['CARRIER']
  carrier_class = (carrier + "RateRequest")
  file = "lib/shipping_consumer/#{carrier_class.underscore}"
  
  services = []
  contexts ||= carrier_class.constantize::SERVICE_CODES
  contexts.each do |context, codes|
    servs = codes.collect {|code,service| {:carrier => carrier, :code => code, :service => service, :context => context} }
    services += servs
  end

  service_codes = YAML.load(File.read("config/service_ids.yml")) || {}
  offset = service_codes.empty? ? 1 : service_codes.keys.sort.last + 1
  services.each_with_index {|service, i| service_codes[i+offset] = service}

  yaml = service_codes.to_yaml
  File.open("config/service_ids.yml","w") {|file| file << yaml}
end  
