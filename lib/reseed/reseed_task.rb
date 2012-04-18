require 'uri'
require 'fileutils'
require 'open-uri'

# Don't allow downloaded files to be created as StringIO. Force a tempfile to be created.
OpenURI::Buffer.send :remove_const, 'StringMax' if OpenURI::Buffer.const_defined?('StringMax')
OpenURI::Buffer.const_set 'StringMax', 0

class ReseedTask

  def execute seeds
    seeds.each do |s|
      if s[:file]
        reseed_file s
      elsif s[:files]
        reseed_files s
      end
    end
  end

  def reseed_file args
    if args[:source][:latest_dir]
      reseed_from_latest_dir args[:source][:latest_dir], args[:file]
    elsif args[:source][:dir]
      reseed_from_dir args[:source][:dir], args[:file]
    elsif args[:source][:web]
      reseed_from_web args[:source][:web], args[:file]
    end
  end

  def reseed_files args
    Dir.glob(args[:files]).each do |f|
      reseed_file { :file => f, :source => args[:source] }
    end
  end

  def reseed_from_latest_dir base_dir, file
    source = Dir[File.join(base_dir, "*")].sort.reverse.first
    reseed_from_dir source, file
  end

  def reseed_from_dir dir, file
    source = File.join(dir, File.basename(file))
    FileUtils.cp source, file 
  end

  def reseed_from_web url, file
    open url do |x|
      FileUtils.cp x.path, file
    end
  end
end