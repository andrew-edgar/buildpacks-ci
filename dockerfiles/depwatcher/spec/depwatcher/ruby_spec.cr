require "spec2"
require "./httpclient_mock"
require "../../src/depwatcher/ruby"

Spec2.describe Depwatcher::Ruby do
  let(client) { HTTPClientMock.new }
  subject { described_class.new.tap { |s| s.client = client } }
  before do
    client.stub_get("https://api.github.com/repos/ruby/ruby/tags?per_page=1000", nil, HTTP::Client::Response.new(200, File.read(__DIR__ + "/../fixtures/github_ruby.json")))
    client.stub_get("https://cache.ruby-lang.org/pub/ruby/index.txt", nil, HTTP::Client::Response.new(200, File.read(__DIR__ + "/../fixtures/ruby_index.txt")))
  end

  describe "#check" do
    it "returns real releases sorted" do
      expect(subject.check.map(&.ref)).to eq [
        "2.2.2", "2.2.3", "2.2.4", "2.2.5", "2.2.6", "2.2.7",
        "2.2.8", "2.2.9", "2.3.0", "2.3.1", "2.3.2", "2.3.3",
        "2.3.4", "2.3.5", "2.3.6", "2.4.0", "2.4.1", "2.4.2", "2.4.3", "2.5.0",
      ]
    end
  end

  describe "#in" do
    it "returns real releases sorted" do
      obj = subject.in("2.5.0")
      if obj
        expect(obj.ref).to eq "2.5.0"
        expect(obj.url).to eq "https://cache.ruby-lang.org/pub/ruby/2.5/ruby-2.5.0.tar.gz"
        expect(obj.sha256).to eq "46e6f3630f1888eb653b15fa811d77b5b1df6fd7a3af436b343cfe4f4503f2ab"
      else
        expect(false).to be_true
      end
    end

    describe "#in2" do
       it "returns real releases when 2.5.7" do
         obj = subject.in("2.5.7")
         if obj
           expect(obj.ref).to eq "2.5.7"
           expect(obj.url).to eq "https://cache.ruby-lang.org/pub/ruby/2.5/ruby-2.5.7.tar.gz"
           expect(obj.sha256).to eq "0b2d0d5e3451b6ab454f81b1bfca007407c0548dea403f1eba2e429da4add6d4"
         else
           expect(false).to be_true
         end
       end
    end
  end
end
