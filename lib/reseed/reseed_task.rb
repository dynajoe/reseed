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
      
      if s[:tfs_checkout] 
        tfs_checkout_dir s[:tfs_checkout_dir]
      end

      if s[:file]
        reseed_file s
      elsif s[:files]
        reseed_files s
      end
    end
  end

  def reseed_file args

    if args[:latest_dir]
      reseed_from_latest_dir args[:latest_dir], args[:file]
    elsif args[:dir]
      reseed_from_dir args[:dir], args[:file]
    elsif args[:web]
      reseed_from_web args[:web], args[:file]
    end

  end

  def reseed_files args
    files = args.delete :files

    Dir.glob(files).each do |f|
      reseed_file({ :file => f }.merge(args))
    end
  end

  def reseed_from_latest_dir base_dir, file
    source = File.join base_dir, Dir.entries(base_dir).sort.reverse.take(1).first
    reseed_from_dir source, file
  end

  def reseed_from_dir dir, file
    source = File.join(dir, File.basename(file))
    reseed source, file 
  end

  def reseed_from_web url, file

    if /\.zip$/i.match url
      extracted_to = download_and_extract url
      reseed_from_dir extracted_to, file
      return
    elsif /(\\|\/)$/.match url
      url += File.basename file
    end

    open url do |x|
      reseed x.path, file
    end
  end

  def reseed source, dest
    base_name = File.basename dest

    if File.exist? source

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

  def tfs_checkout_dir dir
    tfs_checkout File.join dir, "*"
  end

  def tfs_checkout path
   return false unless system TFS_PATH, "get", path, " /force /noprompt"
   return false unless system TFS_PATH, "checkout", path
   return true
 end

 def download_and_extract url_to_zip

  open url_to_zip do |f|
    zip_path = f.path
    puts 'About to unzip the contents of the file to some random directory.'
    return File.dirname zip_path
  end

 end


end