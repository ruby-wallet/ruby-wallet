require 'rest_client'

class Coind::RPC
  def initialize(options)
    @user     = options[:rpc_user]
    @password = options[:rpc_password]
    @host     = options[:rpc_host]
    @port     = options[:rpc_port]
    @ssl      = options[:rpc_ssl]
  end

  def service_url
    url = @ssl ? "https://" : "http://"
    url.concat "#{@user}:#{@password}@#{@host}:#{@port}"
    url
  end

  def dispatch(request)
    begin
      p service_url
      p request.to_post_data
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
