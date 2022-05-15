module SketchupExtensions
  module EngineeringCommunications
    class PipeTool
      CURSOR_PATH = Sketchup.find_support_file("pipe.png", "Plugins/engineering_communications")
      CURSOR_PIPE = UI.create_cursor(CURSOR_PATH, 2, 1)
      CABLE_RADIUS = 10.mm # В модели используются только дюймы, метод mm конвертирует mm в дюймы

      def initialize (name, color) # конструктор класса.
        @name = name # переменная объекта
        @color = color
      end

      # Происходит выбор инструмента в меню или на панели инструментов
      def activate
        @mouse_ip = Sketchup::InputPoint.new
        @picked_first_ip = Sketchup::InputPoint.new
        @first_segment = true

        update_ui
      end

      # Инструмент "отпустили" выбрав другой инструмент или стрелочку
      def deactivate(view)
        # Сигнал что необходимо перерисовать вид
        view.invalidate
      end

      # Возобновление, вызывается когда завершили вращать или перемещать сцену
      def resume(view)
        update_ui
        view.invalidate
      end

      # Приостановка, вызывается конда выбрали покрутить или переместить сцену
      def suspend(view)
        view.invalidate
      end

      # Нажали ESC
      def onCancel(reason, view)
        reset_tool
        view.invalidate
      end

      # Передвинулась мышь с выбранным инструментом
      def onMouseMove(flags, x, y, view)
        if picked_first_point?
          # Установка позиции точки мыши. Включен режим "подсветки"
          @mouse_ip.pick(view, x, y, @picked_first_ip)
        else
          # Установка позиции точки мыши. Включен режим "подсветки"
          @mouse_ip.pick(view, x, y)
        end
        view.tooltip = @mouse_ip.tooltip if @mouse_ip.valid?
        view.invalidate
      end

      # Нажата левая кнопка мыши при выбранном инструменте
      def onLButtonDown(flags, x, y, view)
        # Проверяем была ли ранее выбрана первая точка
        if picked_first_point?
          # Если Выбирается вторая точка Создаем цилиндр
          create_pipe
        end
        # сохраняем координаты мыши в первой точке
        @picked_first_ip.copy!(@mouse_ip)

        update_ui
        view.invalidate
      end

      # Установка курсора инструмента
      def onSetCursor
        UI.set_cursor(CURSOR_PIPE)
      end

      # Перерисовка инструмента, вызывается постоянно при активном инструменте для отрисовки объекта
      def draw(view)
        # Рисуем превью объекта
        draw_preview(view)
        # Рисуем текущую точку мыши
        @mouse_ip.draw(view) if @mouse_ip.display?
      end

      # Получение размеров объекта, нарисовонного инструментом. Вызывается постоянно при отрисовке. Возвращает Geom::BoundingBox вокруг нарисовоного объекта
      def getExtents
        bounds = Geom::BoundingBox.new
        bounds.add(picked_points)
        bounds
      end

      private

      # Обновление объектов интерфейса SketchUp (страки статуса, инструментов итд)
      def update_ui
        if picked_first_point?
          Sketchup.status_text = 'Select end point.'
        else
          Sketchup.status_text = 'Select start point.'
        end
      end

      # Сброс инструмента в исходное состояние, когда не отрисовона ни одной точки
      def reset_tool
        @picked_first_ip.clear
        @first_segment = true
        update_ui
      end

      # Проверка выбрана ли первая точка
      def picked_first_point?
        @picked_first_ip.valid?
      end

      # Метод возвращает массив выбранных точек.
      # В массив входит выбранная точка и положение мыши
      def picked_points
        points = []
        points << @picked_first_ip.position if picked_first_point?
        points << @mouse_ip.position if @mouse_ip.valid?
        points
      end

      # Отрисовка предварительного вида объекта
      def draw_preview(view)
        points = picked_points
        return unless points.size == 2
        view.set_color_from_line(*points)
        view.line_width = 1
        view.line_stipple = ''
        view.draw(GL_LINES, points)
      end

      # Создание цилиндра и места соединения
      def create_pipe
        model = Sketchup.active_model
        group = model.active_entities.add_group
        group.name = @name
        entities = group.entities

        # Векторная алгебра, получаем вектор направления цилиндра
        vector_end = Geom::Vector3d.new @mouse_ip.position.x, @mouse_ip.position.y, @mouse_ip.position.z
        vector_start = Geom::Vector3d.new @picked_first_ip.position.x, @picked_first_ip.position.y, @picked_first_ip.position.z
        vector_cylinder = vector_end - vector_start

        model.start_operation('Circle', true)

        begin
          # рисуем окружность, результат массив ребер
          circle = entities.add_circle(@picked_first_ip, vector_cylinder, CABLE_RADIUS)
          # Создаем плоскость
          cylinder = entities.add_face(circle)
          cylinder.material = @color

          # переворачиваем плоскость если нормаль круга не соврадает с вектором инструмента
          if !cylinder.normal.samedirection?(vector_cylinder)
            cylinder.reverse!
          end

          # Вытягиваем круг на длину вектора, получаем цилиндр
          cylinder.pushpull vector_cylinder.length
          group.set_attribute("engineering_communications", "len", vector_cylinder.length)
          group.set_attribute("engineering_communications", "name", @name)

          # Рисуем шарик в месте стыка
          if !@first_segment
            group_ball = model.active_entities.add_group
            group_ball.name = "Стык кабеля"
            entities_ball = group_ball.entities
            # Используем две взаимно перпендикулярных окружности и инструмент следовать по линии
            circle_ball = entities_ball.add_circle(@picked_first_ip.position, Geom::Vector3d.new(1,0,0), CABLE_RADIUS)
            ball_face = entities_ball.add_face(circle_ball)
            ball_face.material = @color
            path = entities_ball.add_circle(@picked_first_ip.position, Geom::Vector3d.new(0,1,0), CABLE_RADIUS - CABLE_RADIUS / 2 )
            ball_face.followme path
          else
            @first_segment = false
          end

          model.commit_operation
        rescue => exception
          model.abort_operation
          raise exception
        end
      end

    end
  end # module EngineeringCommunications
end # module SketchupExtensions
  