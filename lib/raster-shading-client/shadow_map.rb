class RasterShadingClient::ShadowMap
  include ActiveModel::Serializers::JSON
  include ActiveModel::Validations

  attr_accessor :status, :errors, :callback_id, :callback_url

  def initialize(attributes = {})
    if attributes
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end
  end


  def attributes
    {
        'status' => status,
        'errors' => errors,
        'callback_id' => callback_id,
        'callback_url' => callback_url
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

    handle_response(response)
  end

  def self.handle_response(response)
    json = Yajl::Parser.parse(response.body)
    if response.code == 202
      result = json
    elsif response.timed_out?
      result = { status: 'REQUEST_TIMEOUT', errors: {} }
    elsif response.code == 0
      result = { status: 'REQUEST_NO_RESPONSE', errors: { curl: response.curl_error_message } }
    elsif response.code == 400
      result = json
    elsif response.code == 500
      result = json
    else
      result = { status: 'REQUEST_FAILES', errors: { curl: response.code.to_s } }
    end
    new(result)
  end

  def self.get_shadow_map_uri
    "http://#{RasterShadingClient::Config.host}/api/v1/rastershading"
  end

  def self.callback_id(bbox, azimuth, zenith)
    "#{bbox.sub(',','')}#{azimuth}#{zenith}"
  end


end