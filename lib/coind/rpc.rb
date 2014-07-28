require 'rest_client'

class Coind::RPC
  def initialize(options)
    @user, @pass = options[:rpc_user], options[:rpc_password]
    @host, @port = options[:rpc_host], options[:rpc_port]
    @ssl = options[:rpc_ssl]
  end

  def credentials
    if @user
      "#{@user}:#{@pass}"
    else
      nil
    end
  end

  def service_url
    url = @ssl ? "https://" : "http://"
    url.concat "#{credentials}@" if c = credentials
    url.concat "#{@host}:#{@port}"
    url
  end

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

  private
    def symbolize_keys(hash)
      case hash
      when Hash
        hash.inject({}) do |result, (key, value)|
          key = key.to_sym if key.kind_of?(String)
          value = symbolize_keys(value)
          result[key] = value
          result
        end
      when Array
        hash.collect do |ele|
          symbolize_keys(ele)
        end
      else
        hash
      end
    end
end
