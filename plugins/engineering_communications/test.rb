module SketchupExtensions
  module EngineeringCommunications

    def self.create_cube
      model = Sketchup.active_model
      model.start_operation('Create Cube', true)
      group = model.active_entities.add_group
      entities = group.entities
      points = [
          Geom::Point3d.new(0, 0, 0),
          Geom::Point3d.new(1.m, 0, 0),
          Geom::Point3d.new(1.m, 1.m, 0),
          Geom::Point3d.new(0, 1.m, 0)
      ]
      face = entities.add_face(points)
      face.pushpull(-1.m)
      model.commit_operation
    end

    def self.create_ball
      model = Sketchup.active_model
      model.start_operation('Create Ball', true)
      group = model.active_entities.add_group
      entities = group.entities

      center = Geom::Point3d.new(0, 0, 0)
      direction = Geom::Vector3d.new(1.m, 0, 0)
      radius = 1.m

      circle = entities.add_circle(center, direction, radius)
      circle_face = entities.add_face circle


      direction2 = get_perpendicular(direction)
      path = entities.add_circle(center, direction2, radius)
      circle_face.followme path

      model.commit_operation
    end

    # Получение перпендикуляра к вектору
    def self.get_perpendicular(vector)
      # Так как перпендикулярных векторов бесконечное множество фиксируем Y и Z равным 1, тогда вычисляем X
      result_x = -1 * (vector.y + vector.y)/vector.x
      return Geom::Vector3d.new result_x, 1, 1
    end

  end # module EngineeringCommunications
end # module SketchupExtensions
