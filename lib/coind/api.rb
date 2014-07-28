class Coind::API

  def initialize(options)
    @options = options
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
