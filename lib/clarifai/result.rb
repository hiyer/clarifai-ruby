class Clarifai::Result
  attr_accessor :url, :status_code, :status_msg, :tags, :docid

  def initialize(url:, status_code:, status_msg:, tags:, docid:)
    @url = url
    @status_code = status_code
    @status_msg = status_msg
    @tags = tags
    @docid = docid
  end
end