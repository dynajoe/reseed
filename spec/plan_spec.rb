require 'rspec'
require 'reseed/plan'

describe Plan, "A single seeded dll and using TFS" do
  
  options = { :tfs => true, :to_reseed => [
      { :source => "\\\\bell\\illuminate\builds", :files => "./Shared/seeded.dll" }  
    ]
  }

  plan = Plan::formulate options
  
  it "should have a two steps" do
    plan.steps.count.should eq(2)
  end

  it "should have a TFS step" do
    plan.steps[0].should be_an_instance_of(TFSStep)
  end

  it "should have a file system step" do
    plan.steps[1].should be_an_instance_of(FileSystemStep)
  end

  it "should have planned to checkout the expected files" do
    plan.steps[0].files[0].should eql "./Shared/seeded.dll" 
  end

end
