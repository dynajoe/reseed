require 'rspec'
require 'reseed/file_system_step'
require 'fakefs'

describe FileSystemStep, "#execute" do
  
  context "With single file to copy" do

    FileUtils.mkdir_p "/Poop"

    File.open "/Poop/seeded.dll", "w" do |f|
      f.write "poop"
    end

    files_to_copy = [{ :source => "/Poop/seeded.dll", :dest => "./Shared/seeded.dll" }]

    step = FileSystemStep.new
    step.files_to_copy = files_to_copy

    step.execute

    it "should copy the specified file" do
      File.exist?("./Shared/seeded.dll").should be(true)
    end
  end
  
  context "With multiple files to copy" do
    files_to_copy = [] 

    (1..10).each do |i|
      FileUtils.mkdir_p "/Poop"
     
      File.open "/Poop/#{i}.dll", "w" do |f|
        f.write "#{i}"
      end

      files_to_copy << { :source => "/Poop/#{i}.dll", :dest => "./Shared/#{i}.dll" }
    end

    step = FileSystemStep.new
    step.files_to_copy = files_to_copy

    step.execute

    it "should copy the specified files" do
      (1..10).each do |i|
        File.exist?("./Shared/#{i}.dll").should be(true)
      end
    end
  end

end
