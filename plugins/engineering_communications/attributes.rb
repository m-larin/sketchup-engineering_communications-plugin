module SketchupExtensions
  module EngineeringCommunications
    class Attributes
      def self.open
        attributes = Attributes.new
        attributes.open
      end

      def open
        @dialog ||= create_dialog
        @dialog.set_html(get_html)
        @dialog.visible? ? @dialog.bring_to_front : @dialog.show
      end

      def set_attributes(name)
        model = Sketchup.active_model
        selection = model.selection
        selection.each do |entity|
          entity_name = entity.get_attribute("engineering_communications", "name", default_value = nil)
          if !entity_name.nil?
            entity.set_attribute("engineering_communications", "name", name)
          end
        end
      end

      def get_html

        model = Sketchup.active_model
        selection = model.selection
        names = []
        selection.each do |entity|
          entity_name = entity.get_attribute("engineering_communications", "name", default_value = nil)
          if !names.include?(entity_name)
            names << entity_name
          end
        end

        if names.length == 1
          name = names[0]
        else
          name = ""
        end

        html = <<-HTML
<style>
table, th, td {
  border: 1px solid black;
  border-collapse: collapse;
}
</style>
        
<h1>Атрибуты компонента плагина "Инженерные коммуникации"<h1>

<p><label>Имя: <input id="name" value="#{name}"></label>
<p><button onclick="sketchup.poke(document.getElementById('name').value)">Записать</button>

        HTML
      end

      def create_dialog
        options = {
            :dialog_title => "Attributes",
            :preferences_key => "SketchupExtensions.EngineeringCommunications.Attributes",
            :style => UI::HtmlDialog::STYLE_DIALOG
        }
        dialog = UI::HtmlDialog.new(options)
        dialog.center
        dialog.add_action_callback('poke') do |action_context, name|
          set_attributes(name)
          dialog.close
        end
        dialog
      end
    end
  end
end
