require 'reseed/step'
require 'fileutils'

class FileSystemStep < Step
  attr_accessor :files_to_copy

  def execute
    @files_to_copy.each do |x|
      FileUtils.cp x[:source], x[:dest]    
    end
  end
end
