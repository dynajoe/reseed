require "reseed/version"
require 'reseed/params'
require 'reseed/reseed_task'
require 'rake'
require 'json'
require 'fileutils'

module Reseed

  def self.create_task
    Object.class_eval {
      def reseed(&configblock)
        task :reseed do |t, task_args|
          options = ReseedParams.new
          configblock.call options
          
          task = ReseedTask.new
          task.execute options
        end
      end
    }
  end

  Reseed::create_task
end
