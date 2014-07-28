class Coind::API

  def initialize(options)
    @options = {
      :rpc_user => options[:rpc_user],
      :rpc_host => options[:rpc_host],
      :rpc_port => options['rpc_port'],
      :rpc_ssl  => options['rpc_ssl']
    }
  end

  def to_hash
    @options.dup
  end

  def request(service_name, *params)
    req = Coind::Request.new(service_name, params)
    req.to_json
    Coind::RPC.new(to_hash).dispatch(req)
  end
end
