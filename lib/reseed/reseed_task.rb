require 'uri'
require 'fileutils'
require 'open-uri'

class ReseedTask

  def execute options
    plan = Plan.new
    puts "Formulating plan..."
    plan.formulate options
    puts "Executing plan..."
    plan.execute
  end
end
