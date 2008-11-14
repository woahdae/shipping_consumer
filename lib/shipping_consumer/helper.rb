require 'ruby-debug'
module ShippingConsumer
  module Helper
    # takes a weight in lbz, String or Float (eg "5.6") and returns
    # an array of [lbz, oz] where oz is rounded up to the next oz
    # (eg [5, 10] instead of [5, 9.6])
    def self.weight_in_lbz_oz(weight)
      weight = weight.to_f
      pounds = weight.floor
      decimal = weight - pounds
      ounces = (decimal * 16).ceil
      return [pounds, ounces]
    end
    
    def self.upcase!(*args)
      args.each {|arg| next if !arg; arg.gsub!(/_/, " ") if arg.upcase!}
    end
    
    def self.five_digit_zip!(*args)
      args.each {|arg| arg.to_s.gsub!(/^(.{5}).*/ , "\\1") if arg}
    end
  end
end