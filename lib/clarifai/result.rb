class Clarifai::Result
  attr_accessor :url, :status_code, :status_msg, :tags, :docid, :json

  def initialize(url:, status_code:, status_msg:, tags:, docid:, json:)
    @url = url
    @status_code = status_code
    @status_msg = status_msg
    @tags = tags
    @docid = docid
    @json = json
  end

  def as_json
    @json
  end
end