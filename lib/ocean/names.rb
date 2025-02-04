require "ocean/names/version"
require "rgeo/shapefile"
require "yaml"

module Ocean
  module Names
    class Error < StandardError; end

    def self.reverse_geocode(lat:, lng:)
      geometry_data = point(lat, lng)
      shapes.find do |record|
        record.geometry.contains?(geometry_data) rescue nil
      end&.attributes
    end

    def self.load_shapes
      @shapes = [].tap do |shps|
        RGeo::Shapefile::Reader.open('shape/World_Seas_IHO_v3.shp') do |file|
          file.num_records.times do
            shps << file.next rescue nil
          end
        end
      end
    end

    def self.shapes
      @shapes || load_shapes
    end

    def self.point(lat, lng)
      factory = RGeo::Geos.factory(native_interface: :ffi)
      factory.point(lat, lng)
    end

    # ==== YML usage ====
    module V2
      def self.reverse_geocode(lat:, lng:)
        geometry_data = point(lat, lng)
        shapes.find do |record|
          record.geometry.contains?(geometry_data) rescue nil
        end&.attributes
      end

      def self.load_shapes
        @shapes = YAML.load(File.read("shape/world_seas.yml"))
      end

      def self.shapes
        @shapes || load_shapes
      end

      def self.point(lat, lng)
        factory = RGeo::Geos.factory(native_interface: :ffi)
        factory.point(lat, lng)
      end
    end
  end
end
