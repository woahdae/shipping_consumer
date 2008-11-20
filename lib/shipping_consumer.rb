require 'rubygems'
require 'consumer'

require 'shipping_consumer/shipping_helper' # needs to load first
Dir.glob(File.join(File.dirname(__FILE__), 'shipping_consumer/**/*.rb')).each {|f| require f}
