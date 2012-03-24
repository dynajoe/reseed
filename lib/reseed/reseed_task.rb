require 'uri'
require 'fileutils'
require 'open-uri'

module Reseed

  class ReseedTask

  TFS_PATH = 'c:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\TF.exe'

  def execute options
    puts "Reseeding #{options.name}: "
    
    from = options.source
    dest = options.dest

    source = File.join from, Dir.entries(from).sort.reverse.take(1).first
    files = get_file_paths dest


     
     if f =~ URI::DEFAULT_PARSER.regexp[:ABS_URI] 
       copy_from = open(f).path 
     else
       copy_from = File.join source, base_name
     end
    

    if options.tfs
     puts "  TFS get/checkout"

     files.each do |f|
       if tfs_checkout f
         puts "      #{f}"
       else
         puts "    ! #{f}"
       end
     end
   end

   puts "  Source: #{source}"

   files.each do |f|

     file_name = File.basename f
     
     if File.exist? copy_from
       begin
         FileUtils.cp copy_from, f
         puts "      #{file_name}"
       rescue
         puts "    ! #{file_name} (Unable to copy)"
       end
     else
       puts "    ! #{file_name} (Doesn't exist)"
     end
   end

   puts "Reseed completed! \r\n\r\n"

 end

 def get_file_paths path
   unless path.kind_of? Array
     path = if File.exist? path then [path] else Dir[path] end
     end

     files = []

     path.each do |p|
       files << Dir[p]
     end

     files.flatten.uniq

   end
 end
 
 def get_file_or_path path
   unless File.exist? path
     path = File.dirname path
   end

   path
 end

 def tfs_checkout path
   path = get_file_or_path path

   return false unless system TFS_PATH, "get", path, " /force /noprompt"

   return false unless system TFS_PATH, "checkout", path

   return true
 end
end