require File.dirname(__FILE__) + "/spec_helper"

describe Rate do
  it "should define from_xml" do
    defined?(Rate.new.from_xml).should_not be_nil
  end

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

    # it "for fedex" do
    #   @file = "spec/xml/fedex_rate_response.xml"
    # end
    
    after(:each) do
      xml = File.read("#{@file}")
      raise "need to put example response in #{@file}" if xml.blank?
      
      Rate.from_xml(xml).should_not be_blank
    end
  end
end