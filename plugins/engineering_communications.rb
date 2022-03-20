require 'sketchup.rb'
require 'extensions.rb'

module SketchupExtensions
  module EngineeringCommunications

    unless file_loaded?(__FILE__)
      ex = SketchupExtension.new('Engineering communications', 'engineering_communications/main')
      ex.description = 'Engineering communications.'
      ex.version = '1.0.0'
      ex.copyright = 'Larin Inc © 2022'
      ex.creator = 'Mikhail Larin'
      Sketchup.register_extension(ex, true)
      file_loaded(__FILE__)
    end

  end # EngineeringCommunications
end # SketchupExtensions
