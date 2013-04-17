class RasterShadingClient::ShadowMap
  include ActiveModel::Serializers::JSON
  include ActiveModel::Validations

  attr_accessor :azimuth, :zenith, :bounding_box, :svg

  def initialize(attributes = {})
    if attributes
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end
  end


  def attributes
    {
        'azimuth' => azimuth,
        'zenith' => zenith,
        'bounding_box' => bounding_box,
        'svg' => svg
    }
  end

  def self.get_shadow_map(azimuth, zenith, bounding_box, callback_id)
    response = Typhoeus::Request.new(
        get_shadow_map_uri,
        params: {
          azimuth: azimuth,
          zenith: 90 - zenith,
          bbox: bounding_box,
          id: callback_id
        }).run
    puts response.inspect

    json = Yajl::Parser.parse(response.body)
    new(json['shadow_map'])
  end

  def self.get_shadow_map_uri
    "http://#{RasterShadingClient::Config.host}/api/v1/rastershading"
  end


end


def shadow(current, bounding_box, req_id)
  response_shader = Typhoeus::Request.new(
      uri,
      params: {
          azimuth: current.azimuth,
          zenith: 90 - current.zenith,
          bbox: bounding_box,
          id: req_id
      }
  ).run
end