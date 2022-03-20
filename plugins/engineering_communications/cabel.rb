require 'engineering_communications/pipe.rb'

module SketchupExtensions
  module EngineeringCommunications
    class CabelTool < PipeTool

      def activate
        # Проверка что загружен компонент "Кабель"
        @cabel_component = find_cabel_component
        if !@cabel_component.nil?
          super
        else
          UI::messagebox("Для работы инструмента необходим компонет \"Кабель\"")
        end
      end

      private
      # Создание цилиндра и места соединения
      def create_pipe
        model = Sketchup.active_model
        #group = model.active_entities.add_group
        #group.name = "Кабель"
        entities = model.entities

        # Векторная алгебра, получаем вектор направления цилиндра
        vector_end = Geom::Vector3d.new @mouse_ip.position.x, @mouse_ip.position.y, @mouse_ip.position.z
        vector_start = Geom::Vector3d.new @picked_first_ip.position.x, @picked_first_ip.position.y, @picked_first_ip.position.z
        vector_cylinder = vector_end - vector_start

        begin
          transformation = Geom::Transformation.new(@mouse_ip.position)
          component_instance = entities.add_instance(@cabel_component, transformation)
          component_instance.set_attribute("dynamic_attributes", "LenX", vector_cylinder.length)
        model.commit_operation
        rescue => exception
          model.abort_operation
          raise exception
        end
      end

      def find_cabel_component
        model = Sketchup.active_model
        component_definitions = model.definitions
        component_definitions.each do |component|
          if component.name == "Кабель"
            return component
          end
        end
        return nil
      end

    end
  end # module EngineeringCommunications
end # module SketchupExtensions
