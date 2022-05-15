module SketchupExtensions
  module EngineeringCommunications
    class Report
      def self.generate_report(selected = false)
        report = Report.new
        report.generate(selected)
      end

      def generate(selected)
        @dialog ||= create_dialog
        @dialog.set_html(get_html(selected))
        @dialog.visible? ? @dialog.bring_to_front : @dialog.show
      end

      def get_html(selected)

        model = Sketchup.active_model

        if selected
          entities = model.selection
        else
          entities = model.entities
        end

        # Группируем и суммируем длину компонент
        components = {}
        entities.each do | entity |
          name = entity.get_attribute("engineering_communications", "name", default_value = nil)

          if name != nil
            len = entity.get_attribute("engineering_communications", "len")
            component_len = components[name]
            if component_len.nil?
              component_len = len.to_f
            else
              component_len = component_len + len.to_f
            end
            components[name] = component_len;
          end
        end

        # Формируем таблицу
        table_rows = components.map { |name, len| "<tr><td>" + name + "</td><td>" + len.to_m.round(2).to_s + "</td></tr>" }.join

        html = <<-HTML
<style>
table, th, td {
  border: 1px solid black;
  border-collapse: collapse;
}
</style>
        
<h1>Отчет по компонентам плагина "Инженерные коммуникации"<h1>
<table>

<tr>
  <th>Вид</th>
  <th>Длина(м)</th>
</tr>
#{table_rows}


<tr></tr>
</table>

        HTML
      end

      def create_dialog
        options = {
            :dialog_title => "Report",
            :preferences_key => "SketchupExtensions.EngineeringCommunications.Report",
            :style => UI::HtmlDialog::STYLE_DIALOG
        }
        dialog = UI::HtmlDialog.new(options)
        dialog.center
        dialog
      end
    end
  end
end
