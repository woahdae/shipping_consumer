require File.dirname(__FILE__) + "/spec_helper"
describe Rate do
  describe "should make an instance of itself via from_xml" do
    it "for ups" do
      @file = "spec/xml/ups_rate_response.xml"
    end
    
    it "for usps" do
      @file = "spec/xml/usps_rate_response.xml"
    end
    
    it "for international usps" do
      @file = "spec/xml/usps_intl_rate_response.xml"
    end

    it "for fedex" do
      @file = "spec/xml/fedex_rate_response.xml"
    end
    
    it "for international fedex" do
      @file = "spec/xml/fedex_intl_rate_response.xml"
    end
    
    it "for international to CA fedex" do
      @file = "spec/xml/fedex_intl_to_ca_rate_response.xml"
    end

    after(:each) do
      xml = File.read("#{@file}")
      raise "need to put example response in #{@file}" if xml.blank?
      
      rates = Rate.from_xml(xml)
      rates.should_not be_blank
      
      rates.each do |rate|
        rate.instance_variables.each do |var|
          iv = rate.instance_variable_get(var)
          puts var if iv.nil?
          iv.should_not be_nil
        end
      end
    end
  end
end