module FrontendProxy::Util
  extend self

  TRAILER = "\r\n"
  def chunk(data)
    data ||= ""
    size = data.bytesize
    base_16_size = size.to_s(16)
    [base_16_size,data,nil].join(TRAILER)
  end

  def derackify(headers)
    return {} unless headers
    headers.each_with_object({}) do |original, derackified|
      key, value = original
      next unless key =~ /^HTTP_(.*)/
      derackified[$1] = value
    end
  end

  # we need better header rewriting
  def rewrite!(buffer,api)
    # ghetto rewrite
    # we need to use parsed headers from HTTP parser, rewrite those, then regenerate entire new valid header.
    remove_path_prefix!(buffer, 'api')

    host = api[:host]
    port = api[:port]

    new_host = [host, port].compact.join(':')

    return unless new_host

    change_host!(buffer,new_host)
  end

  def remove_path_prefix!(buffer,subsection)
    return if subsection.empty?

    buffer.sub!(/^([A-Z]+)\s\/#{subsection}/,'')

    if match = $1
      buffer.sub!(/^/, match +' ')
    end
  end

  def change_host!(buffer,new_host)
    buffer.sub!(/^host:\s(.*)\r$/i,"host: #{new_host}\r")
  end

  def authenticate!(buffer,config)
    developer_key = config.fetch(:developer_key)
    user_key = config.fetch(:user_key)

    buffer.sub!(/\r\n$/,'')

    buffer << "X_RADIUM_DEVELOPER_API_KEY: #{developer_key}\r\n"
    buffer << "\r\n"
  end
end
