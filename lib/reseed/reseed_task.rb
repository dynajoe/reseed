module Reseed

  class ReseedTask

  TFS_PATH = 'c:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\TF.exe'

  def execute options

    puts "Reseeding #{options.name}: "

    from = options.source
    dest = options.dest

    latest_build_dir = File.join from, Dir.entries(from).sort.reverse.take(1).first
    files = get_file_paths dest

    unless options.tfs
     puts "  TFS get/checkout"

     files.each do |f|
       if tfs_checkout f
         puts "    ? #{f}"
       else
         puts "    ? #{f}"
       end
     end
   end

   puts "  Copying files from #{latest_build_dir}"

   files.each do |f|
     base_name = File.basename f
     source = File.join latest_build_dir, base_name

     if File.exist? source
       begin
         FileUtils.cp source, f
         puts "    O #{base_name}"
       rescue
         puts "    X #{base_name} (Unable to copy)"
       end
     else
       puts "    ! #{base_name} (Doesn't exist)"
     end
   end

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