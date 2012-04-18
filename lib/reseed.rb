require "reseed/version"
require 'reseed/reseed_task'
require 'rake'
require 'json'
require 'fileutils'

module Reseed

  def self.create_task
    Object.class_eval {
      def reseed(name, &configblock)
        task :"#{name}" do |t, task_args|
          options = []
          configblock.call options
          task = ReseedTask.new
          task.execute options
        end
      end
    }
  end

  Reseed::create_task
end
