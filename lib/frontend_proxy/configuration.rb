require 'logger'

# foreman hack
$stdout.sync = true

module Configuration
  extend self

  def log
    @log ||= Logger.new(STDOUT)
  end

  def api
    @api ||= URI.parse(ENV['API_SERVER'])
  end

  def app
    @app ||= URI.parse(ENV['APP_SERVER'])
  end

  def for(name)
    uri = send(name)
    {
      host: uri.host,
      port: uri.port,
      developer_key: ENV['DEVELOPER_KEY'],
      user_key: ENV['USER_KEY']
    }
  end

  def proxy
    @proxy ||= URI.parse(ARGV.pop)
  end

  def summary
    <<-SUMMARY
Booting Proxy...

  Listening at: #{proxy}

  /api/ -> #{api}
  / -> #{app}

    SUMMARY
  end

  def log_summary
    log.info summary
  end
end

