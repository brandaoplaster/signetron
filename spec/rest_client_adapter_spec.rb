require 'rspec'
require 'webmock/rspec'
require 'rest-client'
require 'singleton'
require_relative '../lib/signetron'

RSpec.describe Signetron::HttpClientInterface do
  describe '#request' do
    it 'raises NotImplementedError when called directly' do
      client = described_class.new
      
      expect {
        client.request(:get, 'https://example.com')
      }.to raise_error(NotImplementedError, "Subclasses must implement request method")
    end
  end
end

RSpec.describe Signetron::RestClientAdapter do
  let(:adapter) { described_class.instance }
  let(:test_url) { 'https://api.example.com/users' }
  
  before { WebMock.enable! }
  after { WebMock.reset! }
  
  describe 'Singleton behavior' do
    it 'returns the same instance' do
      instance1 = described_class.instance
      instance2 = described_class.instance
      
      expect(instance1).to be(instance2)
    end
    
    it 'cannot be instantiated directly' do
      expect { described_class.new }.to raise_error(NoMethodError)
    end
  end
  
  describe '#request' do
    context 'GET requests' do
      it 'makes successful GET request' do
        response_body = { users: [{ id: 1, name: 'John' }] }.to_json
        
        stub_request(:get, test_url)
          .to_return(status: 200, body: response_body)
        
        response = adapter.request(:get, test_url)
        
        expect(response.code).to eq(200)
        expect(response.body).to eq(response_body)
      end
      
      it 'includes headers in GET request' do
        headers = { 'Authorization' => 'Bearer token123' }
        
        stub_request(:get, test_url)
          .with(headers: headers)
          .to_return(status: 200, body: '{}')
        
        response = adapter.request(:get, test_url, {}, headers)
        
        expect(response.code).to eq(200)
      end
    end
    
    context 'POST requests' do
      it 'makes successful POST request with payload' do
        payload = { name: 'John', email: 'john@example.com' }
        
        stub_request(:post, test_url)
          .with(body: payload)
          .to_return(status: 201, body: '{"id": 1}')
        
        response = adapter.request(:post, test_url, payload)
        
        expect(response.code).to eq(201)
      end
      
      it 'sends empty payload when not provided' do
        stub_request(:post, test_url)
          .with(body: {})
          .to_return(status: 201, body: '{}')
        
        response = adapter.request(:post, test_url)
        
        expect(response.code).to eq(201)
      end
    end
    
    context 'PUT requests' do
      it 'makes successful PUT request' do
        payload = { name: 'John Updated' }
        
        stub_request(:put, "#{test_url}/1")
          .with(body: payload)
          .to_return(status: 200, body: '{}')
        
        response = adapter.request(:put, "#{test_url}/1", payload)
        
        expect(response.code).to eq(200)
      end
    end
    
    context 'DELETE requests' do
      it 'makes successful DELETE request' do
        stub_request(:delete, "#{test_url}/1")
          .to_return(status: 204, body: '')
        
        response = adapter.request(:delete, "#{test_url}/1")
        
        expect(response.code).to eq(204)
      end
    end
    
    context 'error handling' do
      it 'raises RestClient::ResourceNotFound for 404' do
        stub_request(:get, test_url).to_return(status: 404)
        
        expect {
          adapter.request(:get, test_url)
        }.to raise_error(RestClient::ResourceNotFound)
      end
      
      it 'raises RestClient::Unauthorized for 401' do
        stub_request(:get, test_url).to_return(status: 401)
        
        expect {
          adapter.request(:get, test_url)
        }.to raise_error(RestClient::Unauthorized)
      end
      
      it 'raises RestClient::Forbidden for 403' do
        stub_request(:get, test_url).to_return(status: 403)
        
        expect {
          adapter.request(:get, test_url)
        }.to raise_error(RestClient::Forbidden)
      end
      
      it 'raises RestClient::InternalServerError for 500' do
        stub_request(:get, test_url).to_return(status: 500)
        
        expect {
          adapter.request(:get, test_url)
        }.to raise_error(RestClient::InternalServerError)
      end
      
      it 'handles network timeouts' do
        stub_request(:get, test_url).to_timeout
        
        expect {
          adapter.request(:get, test_url)
        }.to raise_error(RestClient::RequestTimeout)
      end
    end
    
    context 'parameter types' do
      it 'accepts string methods' do
        stub_request(:get, test_url).to_return(status: 200, body: '{}')
        
        expect {
          adapter.request('get', test_url)
        }.not_to raise_error
      end
      
      it 'accepts symbol methods' do
        stub_request(:get, test_url).to_return(status: 200, body: '{}')
        
        expect {
          adapter.request(:get, test_url)
        }.not_to raise_error
      end
    end
  end
end