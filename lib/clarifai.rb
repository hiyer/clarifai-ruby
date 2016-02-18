require 'clarifai/configuration'
require 'clarifai/result'
require 'rest-client'
require 'json'
require 'uri'

class Clarifai
  class << self
    # Setters for configuration
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Clarifai::Configuration.new
  end

  def self.configure
    yield @configuration if block_given?
  end

  # Returns usage limits for the specified Access Token
  #
  # == Returns:
  # Hash with the usage limits, as specified here:
  # https://developer.clarifai.com/docs/info
  def info
    response = RestClient.request.execute(method: :get, url: "#{@configuration.url_prefix}/info",
      headers: {"Authorization" => "Bearer #{@configuration.access_token}"})
    if response.code == 200
      return JSON.parse(response.body)
    end
    return nil
  end

  # Gets the tags for a set of images
  #
  # == Parameters:
  # image_urls::
  #   An array of URLs to images
  #
  # == Returns:
  # Array of Clarifai::Result items
  def tag(image_urls)
    encoded_urls = image_urls.map { |url| URI.encode(url) }
    response = RestClient.request.execute(method: :post, url: "#{@configuration.url_prefix}/tag",
      headers: {"Authorization" => "Bearer #{@configuration.access_token}", params: {url: encoded_urls}})
    if response.code == 200
      return parse_tag_response(response.body)
    end
    return nil
  end

  # Adds tags for a set of images to improve the image recognition
  #
  # == Parameters:
  # docids::
  #   An array of strings representing the docids for the images
  # tags::
  #   An array of strings representing the new tags for the images
  def add_tags(docids, tags)
    RestClient.request.execute(method: :post, url: "#{@configuration.url_prefix}/feedback",
      headers: {"Authorization" => "Bearer #{@configuration.access_token}",
      params: {docids: docids.join(","), add_tags: tags.join(",")}})
  end

  # Removes tags from a set of images to improve the image recognition
  #
  # == Parameters:
  # docids::
  #   An array of strings representing the docids for the images
  # tags::
  #   An array of strings representing the tags to remove from the images
  def remove_tags(docids, tags)
    RestClient.request.execute(method: :post, url: "#{@configuration.url_prefix}/feedback",
      headers: {"Authorization" => "Bearer #{@configuration.access_token}",
      params: {docids: docids.join(","), remove_tags: tags.join(",")}})
  end

  # Add similar images for a set of images
  #
  # == Parameters:
  # docids::
  #   An array of strings representing the docids for the images
  # similar_docids::
  #   An array of strings representing the docids for the images that are similar to the above
  def add_similar_images(docids, similar_docids)
    RestClient.request.execute(method: :post, url: "#{@configuration.url_prefix}/feedback",
      headers: {"Authorization" => "Bearer #{@configuration.access_token}",
      params: {docids: docids.join(","), similar_docids: tags.join(",")}})
  end

  # Add dissimilar images for a set of images
  #
  # == Parameters:
  # docids::
  #   An array of strings representing the docids for the images
  # dissimilar_docids::
  #   An array of strings representing the docids for the images that are *not* similar to the above
  def add_dissimilar_images(docids, dissimilar_docids)
    RestClient.request.execute(method: :post, url: "#{@configuration.url_prefix}/feedback",
      headers: {"Authorization" => "Bearer #{@configuration.access_token}",
      params: {docids: docids.join(","), dissimilar_docids: tags.join(",")}})
  end

  private
  #   Sample response (v1 API):
  #   [
  #   {
  #     "docid": 11914729235034958001,
  #     "url": "http://d397nxo9hbvzsm.cloudfront.net/uploads/images/scaled_full_012fec4cd8.jpg",
  #     "status_code": "OK",
  #     "status_msg": "OK",
  #     "local_id": "",
  #     "result": {
  #       "tag": {
  #         "concept_ids": [
  #           "ai_gCtlSsl1",
  #           ...
  #         ],
  #         "classes": [
  #           "bathroom",
  #           ...
  #         ],
  #         "probs": [
  #           0.9999986886978149,
  #           ...
  #         ]
  #       }
  #     },
  #     "docid_str": "57250b4ff37e199fa5599f1cc1386570"
  #   },
  #   {
  #     "docid": 11914729235034958002,
  #     "url": "http://d397nxo9hbvzsm.cloudfront.net/uploads/images/scaled_full_012fec5ed8.jpg",
  #     "status_code": "OK",
  #     "status_msg": "OK",
  #     "local_id": "",
  #     "result": {
  #       "tag": {
  #         "concept_ids": [
  #           "ai_gCtlSsl3",
  #           ...
  #         ],
  #         "classes": [
  #           "bathroom",
  #           ...
  #         ],
  #         "probs": [
  #           0.9999825358390808,
  #         ]
  #       }
  #     },
  #     "docid_str": "57250b4ff37e199fa5599f1cc1386586"
  #   }
  # ]

  def parse_tag_response(body)
    ret = []
    results = JSON.parse(body)['results']
    results.each do |result|
      ret << Clarifai::Result.new(docid: result['docid_str'], tags: result['result']['tag']['classes'],
        status_code: result['status_code'], status_msg: result['msg', url: result['url']])
    end

    return ret
  end
end