require 'uri'
require 'fileutils'
require 'open-uri'

TFS_PATH = 'c:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\TF.exe'

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
    if args[:latest_dir]
      reseed_from_latest_dir args[:latest_dir], args[:file], args[:tfs]
    elsif args[:dir]
      reseed_from_dir args[:dir], args[:file], args[:tfs]
    elsif args[:web]
      reseed_from_web args[:web], args[:file], args[:tfs]
    end
  end

  def reseed_files args
    files = args.delete :files

    Dir.glob(files).each do |f|
      reseed_file({ :file => f }.merge(args))
    end
  end

  def reseed_from_latest_dir base_dir, file, checkout
    source = File.join base_dir, Dir.entries(base_dir).sort.reverse.take(1).first
    reseed_from_dir source, file, checkout
  end

  def reseed_from_dir dir, file, checkout
    source = File.join(dir, File.basename(file))
    reseed source, file, checkout 
  end

  def reseed_from_web url, file, checkout
    open url do |x|
      reseed x.path, file, checkout
    end
  end

  def reseed source, dest, checkout
    base_name = File.basename dest

    if File.exist? source

      if checkout 
        tfs_checkout dest
      end
      
      begin
       FileUtils.cp source, dest
       puts "      #{base_name}"
      rescue
       puts "    ! #{base_name} (Unable to copy)"
      end
   else
     puts "    ! #{base_name} (Doesn't exist)"
   end

  end

  def tfs_checkout path
   return false unless system TFS_PATH, "get", path, " /force /noprompt"
   return false unless system TFS_PATH, "checkout", path
   return true
 end

end