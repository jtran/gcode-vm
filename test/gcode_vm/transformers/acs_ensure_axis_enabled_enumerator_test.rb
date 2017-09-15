require 'test_helper'

describe GcodeVm::AcsEnsureAxisEnabledEnumerator do

  class MockAcsSocketForEnableTest
    attr_reader :string_io

    def initialize(responses: [])
      @string_io = StringIO.new
      @responses = responses
    end

    def puts(*args)
      @string_io.puts(*args)
    end

    def request(query)
      self.puts(query)

      @responses.shift
    end
  end

  let(:input) { StringIO.new.tap {|io| io.string = input_text } }

  let(:enum) {
    GcodeVm::AcsEnsureAxisEnabledEnumerator.new(acs_socket: mock_acs_socket)
  }

  describe "when it enables immediately" do

    let(:mock_acs_socket) {
      MockAcsSocketForEnableTest.new(responses: ['1', '1', '1'])
    }

    it "waits for enabling single axis" do
      enum.source_enum = ['one', 'two', 'ENABLE X', 'three'].each
      result = enum.to_a
      result.must_equal ['one', 'two', 'ENABLE X', 'three']
      mock_acs_socket.string_io.string.must_equal "?MST(X).#ENABLED\n"
    end

    it "waits for enabling multiple axes" do
      enum.source_enum = ['one', 'two', 'ENABLE (X,Y, u)', 'three'].each
      result = enum.to_a
      result.must_equal ['one', 'two', 'ENABLE (X,Y, u)', 'three']
      mock_acs_socket.string_io.string.must_equal <<-EOS
?MST(X).#ENABLED
?MST(Y).#ENABLED
?MST(u).#ENABLED
      EOS
    end
  end

  describe "when it doesn't enable immediately" do

    let(:mock_acs_socket) {
      MockAcsSocketForEnableTest.new(responses: ['0', '0', '1', '0', '1', '1'])
    }

    it "waits for enabling single axis" do
      enum.source_enum = ['one', 'two', 'ENABLE X', 'three'].each
      result = enum.to_a
      result.must_equal ['one', 'two', 'ENABLE X', 'three']
      mock_acs_socket.string_io.string.must_equal "?MST(X).#ENABLED\n?MST(X).#ENABLED\n?MST(X).#ENABLED\n"
    end

    it "waits for enabling multiple axes" do
      enum.source_enum = ['one', 'two', 'ENABLE (X,Y, u)', 'three'].each
      result = enum.to_a
      result.must_equal ['one', 'two', 'ENABLE (X,Y, u)', 'three']
      mock_acs_socket.string_io.string.must_equal <<-EOS
?MST(X).#ENABLED
?MST(X).#ENABLED
?MST(X).#ENABLED
?MST(Y).#ENABLED
?MST(Y).#ENABLED
?MST(u).#ENABLED
      EOS
    end
  end

  describe "when the controller responds with an error" do

    let(:mock_acs_socket) {
      MockAcsSocketForEnableTest.new(responses: ['?1234'])
    }

    it "raises an error with the response error code" do
      enum.source_enum = ['one', 'two', 'ENABLE X', 'three'].each
      begin
        enum.to_a
      rescue => e
        e.message.must_equal "There was an error querying the status of a motor when trying to enable it: query=\"?MST(X).#ENABLED\" resp=\"?1234\""
      else
        fail "I epxected the enumerator to raise an error"
      end
    end
  end

end
