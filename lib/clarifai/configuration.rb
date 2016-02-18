class Clarifai::Configuration
  attr_accessor :access_token, :url, :api_version

  def initialize
    @url = 'https://api.clarifai.com'
    @api_version = 1
  end

  def url_prefix
    "#{@url}/v#{@version}"
  end
end