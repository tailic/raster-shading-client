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

  def self.get_shadow_map(azimuth, zenith, bounding_box, datetime)
    cid = callback_id(bounding_box, azimuth, zenith)
    response = Typhoeus::Request.new(
        get_shadow_map_uri,
        params: {
          azimuth: azimuth,
          zenith: 90 - zenith,
          bbox: bounding_box,
          id: cid
        }).run
    return cid if response.code == 202
    return false
  end

  def self.get_shadow_map_uri
    "http://#{RasterShadingClient::Config.host}/api/v1/rastershading"
  end

  def self.callback_id(bbox, azimuth, zenith)
    "#{bbox.sub(',','')}#{azimuth}#{zenith}"
  end


end