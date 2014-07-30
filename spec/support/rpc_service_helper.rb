module RPCServiceHelper
  def service(name, &block)
    context "'#{name}'" do
      define_method :fixture_name do
        suffix = self.class.fixture_suffix.gsub(/\s/, '_')
        if suffix.length > 0
          "#{name}_#{suffix}"
        else
          name
        end
      end
      
      define_method :result do |api_call, *args|
        FakeWeb.register_uri(:post, "http#{'s' if $coin['rpc_ssl']}://#{$coin['rpc_user']}:#{$coin['rpc_password']}@#{$coin['rpc_host']}:#{$coin['rpc_port']}/", :response => fixture(api_call))
        subject.send(name, *args)
      end
      
      class << self
        def fixture_suffix
          @fixture_suffix ||= ""
        end
        
        def context(desc, &block)
          super desc do
            fixture_suffix.concat desc
            instance_eval &block
          end
        end
      end

      instance_eval &block
    end
  end
end
