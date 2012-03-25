require 'reseed/file_system_step'
require 'reseed/http_step'
require 'reseed/tfs_step'

class Plan

  attr_accessor :steps

  def initialize
    @steps = []
  end

  def execute
    steps.each_with_index do |step, index|
      begin
        step.execute
      rescue Exception => e
        puts "Failed executing step #{index + 1} of type #{step.class}."
        puts e.message
      end
    end
  end

  def self.formulate options

    plan = Plan.new

    unless !options[:tfs]
      files = options[:to_reseed].collect do |r|
        r[:files]
      end.flatten

      plan.steps << Plan.create_tfs_step(files)
    end

    options[:to_reseed].each do |r|
      source_type = get_source_type r[:source]

      case source_type
      when :http
        plan.steps << Plan.create_http_step(r[:source], r[:files])
      when :file_system
        plan.steps << Plan.create_fs_step(r[:source], r[:files])
      end
    end

    plan
  end

  def self.create_http_step source, files
    http_step = HttpStep.new

    http_step.files_to_download = files.map { |f| { :source => File.join(source, File.basename(f)), :dest => f } }

    http_step
  end

  def self.create_fs_step source, files
    files_to_copy = []

    if File.directory? source
      files = Plan.expand_files files
      puts files

      files.each do |f|
        files_to_copy << { :source => File.join(source, File.basename(f)), :dest => f } 
      end
    else
      files_to_copy = [ { :source => source, :dest => files[0] } ]
    end

    fs_step = FileSystemStep.new
    fs_step.files_to_copy = files_to_copy
    fs_step
  end

  def self.expand_files files
    files.map do |f| 
      if File.exist? f
        [f]
      else
        Dir[f]
      end
    end.flatten
  end

  def self.create_tfs_step files
    tfs_step = TFSStep.new

    tfs_step.files = get_files_from_paths files.flatten.uniq

    tfs_step
  end

  def self.get_source_type source
    if source =~ URI::DEFAULT_PARSER.regexp[:ABS_URI] and source =~ /^http/i
      :http
    else
      :file_system
    end
  end

  def self.get_files_from_paths paths

    files = []

    paths.each do |path|
      files = []

      if path.include? "*"
        path.each do |p|
          files << Dir[p]
        end

        files.flatten.uniq
      else
        files << path
      end
    end

    files
  end
end
