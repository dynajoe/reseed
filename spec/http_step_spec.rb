require 'rspec'
require 'tempfile'
require 'reseed/http_step'
require 'fakefs'
require 'fakeweb'

describe HttpStep, "#execute" do

  Dir.mkdir "tmp"
  File.open "tmp/seeded.dll", "w" do |f|
    f.write "poop"
  end

  FakeWeb.register_uri :any, "http://build-server/latest/seeded.dll", :body => File.open("tmp/seeded.dll", "r")

  files_to_download = [{:source => "http://build-server/latest/seeded.dll", :dest => "./Shared/seeded.dll"}]

  step = HttpStep.new
  step.files_to_download = files_to_download
  step.execute

  context "With a single file to download" do
    File.exist?("./Shared/seeded.dll").should be(true)  
  end
  
end
