require 'riak'

# we don't need no stinking warnings :-)
Riak.disable_list_keys_warnings = true

class Cluster
  attr_reader :connection

  # Connect to Riak and test the client connection.
  def initialize(cluster_name)
    begin
      config_path = File.join(ROOT,'config.yml')
      config = Hash[YAML.load_file(config_path)[cluster_name].map{|k,v| [k.to_sym, v]}]
      @connection = Riak::Client.new(:nodes => [config])
      bucket = @connection.bucket("test") 
      object = bucket.get_or_new("test") 
    rescue RuntimeError
      raise RuntimeError, "Could not connect to the Riak node '#{cluster_name}'."
    end
  end
end
