require 'rest-client'
require 'json'
require 'uri'

class Clarifai
  class << self
    # Setters for configuration
    attr_writer :configuration, :token, :token_expiry
  end

  def self.configuration
    @configuration ||= Clarifai::Configuration.new
  end

  def self.configure
    yield configuration if block_given?
  end

  def self.access_token
    if @token && @token_expiry && ((@token_expiry - Time.now) > 300.0)
      return @token
    end

    response = RestClient.post "#{configuration.url_prefix}/token",
      {client_id: configuration.client_id, client_secret: configuration.client_secret, grant_type: 'client_credentials'}

    json = JSON.parse(response.body)
    @token_expiry = Time.now + (json['expires_in'] || 176400)
    @token = json['access_token']
  end

  # Returns usage limits for the specified Access Token
  #
  # == Returns:
  # Hash with the usage limits, as specified here:
  # https://developer.clarifai.com/docs/info
  def self.info
    response = RestClient.get "#{configuration.url_prefix}/info", {Authorization: "Bearer #{access_token}"}
    return JSON.parse(response.body)
  end

  # Gets the tags for a set of images
  #
  # == Parameters:
  # image_urls::
  #   An array of URLs to images
  #
  # == Returns:
  # Array of Clarifai::Result items
  def self.tag(image_urls)
    encoded_urls = []
    image_urls.each do |url|
      encoded_urls << ['url', url]
    end
    response = RestClient.post "#{configuration.url_prefix}/tag", URI::encode_www_form(encoded_urls),
      { Authorization: "Bearer #{access_token}" }

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
  def self.add_tags(docids, tags)
    response = RestClient.post "#{configuration.url_prefix}/feedback",
      {docids: URI.encode(docids.join(",")), add_tags: URI.encode(tags.join(","))},
      {Authorization: "Bearer #{access_token}"}

    if response.code != 201
      raise "Error adding tags: #{response.body}"
    end
  end

  # Removes tags from a set of images to improve the image recognition
  #
  # == Parameters:
  # docids::
  #   An array of strings representing the docids for the images
  # tags::
  #   An array of strings representing the tags to remove from the images
  def self.remove_tags(docids, tags)
    response = RestClient.post "#{configuration.url_prefix}/feedback",
      {docids: URI.encode(docids.join(",")), remove_tags: URI.encode(tags.join(","))},
      {Authorization: "Bearer #{access_token}"}

    if response.code != 201
      raise "Error removing tags: #{response.body}"
    end
  end

  # Add similar images for a set of images
  #
  # == Parameters:
  # docids::
  #   An array of strings representing the docids for the images
  # similar_docids::
  #   An array of strings representing the docids for the images that are similar to the above
  def self.add_similar_images(docids, similar_docids)
    response = RestClient.post "#{configuration.url_prefix}/feedback",
      {docids: URI.encode(docids.join(",")), similar_docids: URI.encode(similar_docids.join(","))},
      {Authorization: "Bearer #{access_token}"}

    if response.code != 201
      raise "Error adding similar images: #{response.body}"
    end
  end

  # Add dissimilar images for a set of images
  #
  # == Parameters:
  # docids::
  #   An array of strings representing the docids for the images
  # dissimilar_docids::
  #   An array of strings representing the docids for the images that are *not* similar to the above
  def self.add_dissimilar_images(docids, dissimilar_docids)
    response = RestClient.post "#{configuration.url_prefix}/feedback", {docids: docids.join(","),
      dissimilar_docids: dissimilar_docids.join(",")},
      {Authorization: "Bearer #{access_token}"}

    if response.code != 201
      raise "Error adding dissimilar images: #{response.body}"
    end
  end

  private
  require 'clarifai/result'
  def self.parse_tag_response(body)
    #   Sample response (v1 API):
    #   [
    #   {
    #     "docid": 11914729236034958001,
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
    #     "docid": 11914729236034958002,
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
    #
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

    ret = []
    results = JSON.parse(body)['results']
    return nil if !results
    results.each do |result|
      ret << Clarifai::Result.new(docid: result['docid_str'], tags: result['result']['tag']['classes'],
        status_code: result['status_code'], status_msg: result['status_msg'], url: result['url'], json: result)
    end

    return ret
  end
end

require 'clarifai/configuration'