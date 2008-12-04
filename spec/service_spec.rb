require File.dirname(__FILE__) + "/spec_helper"

describe Service do
  describe "find" do
    it "should return the correct Service" do
      service = Service.find(1)
      service.name.should == "Priority Mail Large Flat-Rate Box"
      service.carrier.should == "USPS"
      service.code.should == "22"
      service.context.should == "Domestic"
    end
  end

  describe "find_by_attributes" do
    it "should return the correct Service" do
      service = Service.find_by_attributes({:context => "Domestic", :carrier=>"USPS", :code=>"22"})
      service.name.should == "Priority Mail Large Flat-Rate Box"
      service.id.should == 1
    end
  end
end