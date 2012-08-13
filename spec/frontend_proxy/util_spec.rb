require './lib/frontend_proxy'

describe FrontendProxy::Util do
  describe '.derackify' do
    subject do
      FrontendProxy::Util.derackify(env)
    end

    describe 'nil env' do
      let(:env) { }

      it { should == {} }
    end

    describe 'empty env' do
      let(:env) {{}}

      it { should == {} }
    end

    describe 'mixed env' do
      let(:env) do
        {
          'HTTP_VERSION' => 'HTTP/1.1',
          'rack.url_scheme' => 'http',
          'REMOTE_ADDR' => '127.0.0.1'
        }
      end
      it do
        should == { 'VERSION' => 'HTTP/1.1'}
      end
    end

  end

  describe '.chunk' do
    subject do
      FrontendProxy::Util.chunk(data)
    end

    describe 'nil data' do
      let(:data) { }
      it { should == "0\r\n\r\n" }
    end

    describe 'empty data' do
      let(:data) { '' }

      it { should == "0\r\n\r\n" }
    end

    describe 'short data' do
      let(:data) { 'This is the data in the first chunk' }
      it { should == "23\r\nThis is the data in the first chunk\r\n" }
    end

  end

  describe '.rewrite!' do
    before do
      FrontendProxy::Util.rewrite!(buffer, options)
    end

    subject { buffer }

    let(:buffer) { original_buffer.clone }

    context 'change host to google' do
      let(:original_buffer) do
        <<-HEADERS
GET /users Http1.1 \r\n
host: apple.com \r\n
      HEADERS
      end

      let(:options) do
        {
          host: 'google.com'
        }
      end

      it 'google is the new host' do
        should =~ /host: google.com/
      end
    end
  end

  describe '.remove_path_prefix!' do
    subject { buffer }

    before do
      FrontendProxy::Util.remove_path_prefix!(buffer,path_prefix)
    end

    let(:request_and_path_with_prefix) do
      'GET /api/users'
    end

    context 'valid path' do
      let(:buffer) { request_and_path_with_prefix.clone }

      context 'no path prefix' do
        let(:path_prefix) { '' }
        it do
          should == request_and_path_with_prefix
        end
      end

      context 'with path prefix' do
        let(:path_prefix) { 'api' }
        it { should_not == request_and_path_with_prefix }
        it { should == 'GET /users' }

      end
    end
  end

  describe '.change_host!' do
    subject { buffer }

    before do
      FrontendProxy::Util.change_host! buffer, new_host
    end

    context 'valid buffer and valid new_host' do
      let(:buffer)   { "host: example.com\r" }
      let(:new_host) { "google.com" }

      it do
        should == "host: google.com\r"
      end

    end
  end

  describe '.authenticate' do

  end

end
