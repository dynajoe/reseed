require 'rspec'
require 'reseed/plan'
require 'fakefs'

describe Plan, ".formulate" do
  
  context "A single seeded dll and using TFS" do
    options = { 
      :tfs => true, 
      :to_reseed => [ { :source => "\\\\bell\\illuminate\builds", :files => "./Shared/seeded.dll" } ]
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

  context "Multiple seeded dlls and not using TFS" do
    
    options = { :to_reseed => [] } 
    options[:to_reseed] << { :source => ".", :files => ["./Shared/first.dll", "./Shared/second.dll"] } 
    
    plan = Plan::formulate options  
    
    it "should have one step for the single source" do
      plan.steps.count.should eq(1)
    end

    it "should plan on reseeding two dlls" do
      plan.steps[0].files_to_copy.count.should eq(2)
    end

    it "should plan on reseeding the first dll from the specified location" do
      plan.steps[0].files_to_copy[0][:source].should eq("./first.dll")
    end

    it "should plan on reseeding the first over the old dll" do 
      plan.steps[0].files_to_copy[0][:dest].should eq("./Shared/first.dll")
    end

    it "should plan on reseeding the second dll from the specified location" do
      plan.steps[0].files_to_copy[1][:source].should eq("./second.dll")
    end

    it "should plan on reseeding the second over the old dll" do 
      plan.steps[0].files_to_copy[1][:dest].should eq("./Shared/second.dll")
    end

  end

  context "With a source that is a website directory" do
    options = { :to_reseed => [] } 
    options[:to_reseed] << { :source => "http://build-server/latest/", :files => ["./Shared/webly.dll"] } 
    
    plan = Plan::formulate options  
    
    it "should plan to download the dll from the correct location" do
      plan.steps[0].files_to_download[0][:source].should eq("http://build-server/latest/webly.dll") 
    end
    
    it "should plan to overwrite the correct file" do
      plan.steps[0].files_to_download[0][:dest].should eq("./Shared/webly.dll") 
    end 
  end
end
