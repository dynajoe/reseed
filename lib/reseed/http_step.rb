require 'reseed/step'
require 'open-uri'

# Don't allow downloaded files to be created as StringIO. Force a tempfile to be created.
OpenURI::Buffer.send :remove_const, 'StringMax' if OpenURI::Buffer.const_defined?('StringMax')
OpenURI::Buffer.const_set 'StringMax', 0

class HttpStep < Step
  attr_accessor :files_to_download

  def execute
    @files_to_download.each do |f|
      open f[:source] do |x|
        puts x.path
        FileUtils.cp x.path, f[:dest]
      end
    end
  end

end
