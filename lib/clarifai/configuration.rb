class Clarifai::Configuration
  attr_accessor :url, :api_version, :client_id, :client_secret

  def initialize
    @url = 'https://api.clarifai.com'
    @api_version = 1
  end

  def url_prefix
    "#{@url}/v#{@api_version}"
  end
end