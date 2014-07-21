require 'rest_client'

class Coind::RPC
  def initialize(options)
    @user, @pass = options[:user], options[:pass]
    @host, @port = options[:host], options[:port]
    @ssl = options[:ssl]
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

  # Need to rebuild this function, it is poorly implemented
  def dispatch(request)
    begin
      respdata = RestClient.post service_url, request.to_post_data
      p respdata
      response = JSON.parse(respdata)
      raise Coin::Errors::RPCError, response['error'] if response['error']
      return response['result']
    rescue => e
      p e.to_s
      p response
      #response = JSON.parse(e.to_s)
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
