module ShippingConsumer
  module ShippingHelper
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
    
    # sorts rates by price, and puts them into a hash of the form 
    # 'carrier' => [rates for carrier]
    def self.rates_by_carrier(rates)
      rates = rates.sort {|a,b| a.price.to_f <=> b.price.to_f}
      carriers = rates.collect {|r| r.carrier}.uniq
      result = {}
      carriers.each do |carrier|
        result[carrier] = rates.find_all {|r| r.carrier == carrier}
      end

      return result
    end
    
    def self.services_by_carrier(carriers = nil)
      carriers ||= ["UPS","USPS","Fedex"]
      carriers_hash = {}
      carriers.each do |carrier|
        carriers_hash[carrier] = []
      end
      
      Service::SERVICE_IDS.each do |id,service|
        carriers_hash[service[:carrier]] << Service.new(service.merge(:id => id)) unless carriers_hash[service[:carrier]].nil?
      end
      
      return carriers_hash
    end

    def self.services_by_carrier_and_context(services_by_carrier_hash = nil)
      services_by_carrier_hash = services_by_carrier_hash ? services_by_carrier_hash.dup : self.services_by_carrier
      services_by_carrier_hash.each do |carrier, services|
        contexts = {}

        services.each do |service|
          contexts[service[:context]] ||= []
          contexts[service[:context]] << service
        end

        contexts.values.each {|services| services.sort! {|a,b| a[:name] <=> b[:name]}}
        services_by_carrier_hash[carrier] = contexts
      end
      
      return services_by_carrier_hash
    end

  end
end