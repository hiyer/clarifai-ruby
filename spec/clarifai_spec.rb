require 'spec_helper'
require 'clarifai'
require 'uri'

class FakeResponse
  attr_accessor :status_code, :body

  def initialize(status_code=nil, body=nil)
    @status_code = status_code || 200
    @body = body || '{"foo": "bar"}'
  end

  def code
    @status_code
  end
end

describe Clarifai do
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
        body = <<-EOJ
        {"results":[{"docid":11914729235034957158,"url":"http://jdkskdjslkds.cloudfront.net/uploads/images/scaled_full_012fec4cd8.jpg",
          "status_code":"OK","status_msg":"OK","local_id":"","result":{"tag":{"concept_ids":["ai_gCtlSsl1","ai_VJf52zcJ","ai_TnmxF3rz",
            "ai_X8N92R0N","ai_7fhDkL1r","ai_1h7cBX3K","ai_SJFQxZds","ai_5qc1wjSB","ai_bW9dQlzk","ai_BzsVx8gl","ai_flbnb9XM",
            "ai_kbGZRr5S","ai_dGVpFsQP","ai_CLx6ltMq","ai_9wXZRTp6","ai_cqbSGjCj","ai_j09mzT6j","ai_MmRdqDFp","ai_KrxS4bmw","ai_XNpR6lwb"],
            "classes":["bathroom","bathroom","lavatory","faucet","bathtub","shower","bath","washroom","water closet","wash","flush",
            "fixture","sanitary","urine","wash","plumbing","family","soap","ceramic","inside"],
            "probs":[0.9999986886978149,0.9999825358390808,0.9999593496322632,0.9999401569366455,0.9999396204948425,0.9997832775115967,
            0.9997101426124573,0.9996253252029419,0.999205470085144,0.9991880655288696,0.9991191625595093,0.9985856413841248,
            0.9981468915939331,0.9977301359176636,0.9971402883529663,0.9969378113746643,0.9968108534812927,0.9965347051620483,
            0.9950788021087646,0.9940170049667358]}},"docid_str":"57250b4ff37e199fa5599f1cc1386566"},
        {"docid":4291469842934172077,"url":"http://dsdlsdlkjsdlsjdl.cloudfront.net/uploads/images/scaled_full_972cb453cd.jpg",
        "status_code":"OK","status_msg":"OK","local_id":"","result":{"tag":{"concept_ids":["ai_gCtlSsl1","ai_VJf52zcJ","ai_TnmxF3rz",
        "ai_X8N92R0N","ai_7fhDkL1r","ai_1h7cBX3K","ai_5qc1wjSB","ai_BzsVx8gl","ai_SJFQxZds","ai_bW9dQlzk","ai_dGVpFsQP","ai_flbnb9XM",
        "ai_9wXZRTp6","ai_CLx6ltMq","ai_dQFGCPgf","ai_MmRdqDFp","ai_kbGZRr5S","ai_D5KjgBR3","ai_KrxS4bmw","ai_8FQp9WWs"],
        "classes":["bathroom","bathroom","lavatory","faucet","bathtub","shower","washroom","wash","bath","water closet","sanitary",
        "flush","wash","urine","hygiene","soap","fixture","mirror","ceramic","clean"],"probs":[0.9999995827674866,0.999995231628418,
        0.9999855756759644,0.9999756813049316,0.9999747276306152,0.9999220371246338,0.9998465776443481,0.9996713995933533,0.9996517896652222,
        0.9990396499633789,0.9987533092498779,0.9987452030181885,0.9982078075408936,0.9962869882583618,0.9961229562759399,0.9960118532180786,
        -2.01,0.9921805262565613,0.991962194442749,0.9918220043182373]}},"docid_str":"6aaff1c44627ebab3b8e5d15c06489ad"}]}
      EOJ

        allow(RestClient::Request).to receive(:execute).and_return(FakeResponse.new(200, body))
        expect(RestClient::Request).to receive(:execute).with(method: :post, url: "https://api.clarifai.com/v1/tag",
          headers: {Authorization: "Bearer foobar" }, payload: URI::encode_www_form([['url', 'http://www.example.com/foo.jpg']]))
        response = Clarifai.tag(['http://www.example.com/foo.jpg'])
        expect(response.length).to eq(2)
        expect(response[0].docid).to eq("57250b4ff37e199fa5599f1cc1386566")
        expect(response[1].docid).to eq("6aaff1c44627ebab3b8e5d15c06489ad")

        expect(response[0].url).to eq("http://jdkskdjslkds.cloudfront.net/uploads/images/scaled_full_012fec4cd8.jpg")
        expect(response[1].url).to eq("http://dsdlsdlkjsdlsjdl.cloudfront.net/uploads/images/scaled_full_972cb453cd.jpg")

        response.each do |result|
          expect(result.tags).to include("bathroom")
          expect(result.status_code).to eq("OK")
          expect(result.status_msg).to eq("OK")
        end
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

  describe "access token" do
    before(:all) do
      Clarifai.configure do |c|
        c.client_id = 'abc'
        c.client_secret = 'xyz'
      end
    end

    it "fetches access token only once" do
      allow(RestClient::Request).to receive(:execute).and_return(FakeResponse.new(200, '{"access_token": "foobar", "expires_in": 5000}'))
      expect(RestClient::Request).to receive(:execute).once
      3.times do
        Clarifai.access_token
      end
    end
  end
end