require File.dirname(__FILE__) + "/spec_helper"

describe RateRequest do
  
  if ENV['DO_IT_LIVE']
    describe "get_multiple" do
      it "should get rates from multiple carriers" do
        $DEBUG = true
        rates = RateRequest.get_multiple({
          :zip => "98125",
          :country => "US",
          :weight => "5.6"
        })
              
        rates.size.should_not be_blank
      end
      
      it "should get international rates from multiple carriers" do
        $DEBUG = true
        rates = RateRequest.get_multiple({
          :country => "CA",
          :weight => "5.6"
        })
        
        rates.size.should_not be_blank
      end
    end
  end

  describe "add_id_to_rates" do
    
    it "should set the id field on all the rates from SERVICE_IDS" do
      @ups_file = "spec/xml/ups_rate_response.xml"
      @usps_file = "spec/xml/usps_rate_response.xml"
      ups_xml = File.read("#{@ups_file}")
      usps_xml = File.read("#{@usps_file}")
      
      rates = Rate.from_xml(ups_xml)
      rates += Rate.from_xml(usps_xml)
      
      rates = RateRequest.add_id_to_rates(rates)

      rates.each do |rate|
        puts rate.inspect if rate.id.nil?
        rate.id.should_not be_nil
      end
    end
  end

  describe "method_from_id" do
    it "should return a method hash" do
      RateRequest.method_from_id(1).should == {:service=>"Priority Mail Flat0Rate Large Box", :carrier=>"USPS", :code=>"22"}
    end
  end

  describe "id_from_method" do
    it "should return a method hash" do
      RateRequest.id_from_method({:service=>"Priority Mail Flat0Rate Large Box", :carrier=>"USPS", :code=>"22"}).should == 1
    end
  end

end