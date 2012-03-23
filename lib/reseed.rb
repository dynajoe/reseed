# encoding: utf-8
require "reseed/version"
require 'rake'
require 'json'
require 'fileutils'

module Reseed

   TFS_PATH = 'c:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\TF.exe'

   class ReseedParams
     attr_accessor :tfs
     attr_accessor :source
     attr_accessor :dest
     attr_accessot :name
   end

   def reseed 
     options = ReseedParams.new

     yield options

     puts "Reseeding #{options.name}: "

     from = options.from
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
