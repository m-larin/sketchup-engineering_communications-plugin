require 'sketchup.rb'
require 'engineering_communications/cabel.rb'
require 'engineering_communications/pipe.rb'
require 'engineering_communications/test.rb'
require 'engineering_communications/report.rb'
require 'engineering_communications/attributes.rb'

module SketchupExtensions
  module EngineeringCommunications

    def self.activate_pipe_tool(name, color)
      Sketchup.active_model.select_tool(PipeTool.new(name, color))
    end

    def self.create_report(selected = false)
      Report.generate_report(selected)
    end

    def self.set_attributes
      Attributes.open
    end

    unless file_loaded?(__FILE__)
      plugins_menu = UI.menu('Plugins')
      plugin_menu = plugins_menu.add_submenu("Инженерные коммуникации")

      plugin_menu.add_item('Кабель ВВГ-3х2,5') {
        self.activate_pipe_tool("ВВГ-3х2,5", Sketchup::Color.new(192, 192, 192))
      }
      plugin_menu.add_item('Кабель ВВГ-3х1,5') {
        self.activate_pipe_tool("ВВГ-3х1,5", Sketchup::Color.new(192, 192, 192))
      }
      plugin_menu.add_item('Труба СП-16') {
        self.activate_pipe_tool("СП-16", Sketchup::Color.new(120, 120, 120))
      }
      plugin_menu.add_item('Труба СП-20') {
        self.activate_pipe_tool("СП-20", Sketchup::Color.new(120, 120, 120))
      }
      plugin_menu.add_item('Отчет') {
        self.create_report
      }
      plugin_menu.add_item('Отчет по выделенным') {
        self.create_report(true)
      }
      plugin_menu.add_item('Установить атрибуты') {
        self.set_attributes
      }
      file_loaded(__FILE__)
    end

  end # module EngineeringCommunications
end # module SketchupExtensions
