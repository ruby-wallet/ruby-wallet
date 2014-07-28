require 'rest_client'

class Coind::RPC
  def initialize(options)
    @user, @password = options[:rpc_user], options[:rpc_password]
    @host, @port = options[:rpc_host], options[:rpc_port]
    @ssl = options[:rpc_ssl]
  end

  def service_url
    url = @ssl ? "https://" : "http://"
    url.concat "#{@user}:#{@password}@#{@host}:#{@port}"
    url
  end

  # Needs massive improvement, is rest_client even necessary? why not net/http net/https?
  def dispatch(request)
    begin
      respdata = RestClient.post service_url, request.to_post_data
      response = JSON.parse(respdata)
      return response['result']
    rescue => error
      begin
        response = JSON.parse(error.to_s)
      rescue
        response = {'error' => error.to_s}
      end
      return response
    end
  end

end
