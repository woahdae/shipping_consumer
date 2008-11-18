$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'shipping_consumer'

class Numeric
  def empty?
    false
  end
end

class Object
  def blank?
    self.nil? || self.empty?
  end
end
