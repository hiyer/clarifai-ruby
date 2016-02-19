require 'spec_helper'
require 'clarifai'
require 'uri'

class FakeResponse
  attr_accessor :status_code

  def initialize(status_code=nil)
    @status_code = status_code || 200
  end

  def code
    @status_code
  end

  def body
    '{"foo": "bar"}'
  end
end

describe Clarifai do
  before(:all) do
    Clarifai.configure do |config|
      config.client_id = 'abc'
      config.client_secret = 'xyz'
    end
  end

  describe "apis" do
    before(:each) do
      allow(Clarifai).to receive(:access_token).and_return("foobar")
    end

    describe "info" do
      it "gets user info" do
        allow(RestClient::Request).to receive(:execute).and_return(FakeResponse.new)
        expect(RestClient::Request).to receive(:execute).with(method: :get, url: "https://api.clarifai.com/v1/info", headers: {Authorization: "Bearer foobar" })
        json = Clarifai.info
        expect(json['foo']).to eq('bar')
      end
    end

    describe "get tags" do
      it "gets tags" do
        allow(RestClient::Request).to receive(:execute).and_return(FakeResponse.new)
        expect(RestClient::Request).to receive(:execute).with(method: :post, url: "https://api.clarifai.com/v1/tag",
          headers: {Authorization: "Bearer foobar" }, payload: URI::encode_www_form([['url', 'http://www.example.com/foo.jpg']]))
        Clarifai.tag(['http://www.example.com/foo.jpg'])
      end
    end

    describe "add tags" do
      it "adds tags" do
        allow(RestClient::Request).to receive(:execute).and_return(FakeResponse.new(201))
        expect(RestClient::Request).to receive(:execute).with(method: :post, url: "https://api.clarifai.com/v1/feedback",
          headers: {Authorization: "Bearer foobar" }, payload: {docids: 'abcdef123456', add_tags: 'foo,bar'})
        Clarifai.add_tags(['abcdef123456'], ['foo', 'bar'])
      end
    end

    describe "remove tags" do
      it "removes tags" do
        allow(RestClient::Request).to receive(:execute).and_return(FakeResponse.new(201))
        expect(RestClient::Request).to receive(:execute).with(method: :post, url: "https://api.clarifai.com/v1/feedback",
          headers: {Authorization: "Bearer foobar" }, payload: {docids: 'abcdef123456', remove_tags: 'foo,bar'})
        Clarifai.remove_tags(['abcdef123456'], ['foo', 'bar'])
      end
    end

    describe "similar docs" do
      it "adds similar docids" do
        allow(RestClient::Request).to receive(:execute).and_return(FakeResponse.new(201))
        expect(RestClient::Request).to receive(:execute).with(method: :post, url: "https://api.clarifai.com/v1/feedback",
          headers: {Authorization: "Bearer foobar" }, payload: {docids: 'abcdef123456', similar_docids: 'foo,bar'})
        Clarifai.add_similar_images(['abcdef123456'], ['foo', 'bar'])
      end
    end

    describe "dissimilar docs" do
      it "adds dissimilar docids" do
        allow(RestClient::Request).to receive(:execute).and_return(FakeResponse.new(201))
        expect(RestClient::Request).to receive(:execute).with(method: :post, url: "https://api.clarifai.com/v1/feedback",
          headers: {Authorization: "Bearer foobar" }, payload: {docids: 'abcdef123456', dissimilar_docids: 'foo,bar'})
        Clarifai.add_dissimilar_images(['abcdef123456'], ['foo', 'bar'])
      end
    end
  end
end