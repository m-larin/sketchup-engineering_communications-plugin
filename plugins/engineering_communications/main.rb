require 'sketchup.rb'
require 'engineering_communications/cabel.rb'
require 'engineering_communications/pipe.rb'
require 'engineering_communications/test.rb'
require 'engineering_communications/report.rb'
require 'engineering_communications/attributes.rb'

module SketchupExtensions
  module EngineeringCommunications

    def self.activate_pipe_tool
      Sketchup.active_model.select_tool(PipeTool.new)
    end

    def self.activate_cabel_tool
      Sketchup.active_model.select_tool(CabelTool.new)
    end

    def self.create_report
      Report.generate_report
    end

    def self.set_attributes
      Attributes.open
    end

    unless file_loaded?(__FILE__)
      plugins_menu = UI.menu('Plugins')
      plugin_menu = plugins_menu.add_submenu("Инженерные коммуникации")

      plugin_menu.add_item('Создать кабель ВВГ-3х2,5') {
        self.activate_pipe_tool
      }
      plugin_menu.add_item('Отчет') {
        self.create_report
      }
      plugin_menu.add_item('Установить атрибуты') {
        self.set_attributes
      }
      file_loaded(__FILE__)
    end

  end # module EngineeringCommunications
end # module SketchupExtensions
