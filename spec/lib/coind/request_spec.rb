require 'spec_helper'

describe Coind::Request do
  it "omits null arguments and everything after them" do
    # coind rejects null values even for optional params. Since
    # even params following those may have default non-nil values,
    # we'll assume the first non-nil value marks a set of optional
    # params, and drop it and everything following it.

    req = Coind::Request.new('svc', [1, nil, nil, nil])
    expect(req.params).to match_array([1])
    
    req = Coind::Request.new('svc', [nil])
    expect(req.params).to match_array([])
    
    req = Coind::Request.new('svc', [1, nil, nil, 1, nil])
    expect(req.params).to match_array([1])
  end
end
