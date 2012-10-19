namespace :riak do
  namespace :log_keys do
    desc "Write all of the keys in Cluster A to a csv file."
    task :A do
      LogKeys.new("A").run
    end

    desc "Write all of the keys in Cluster B to a csv file."
    task :B do
      LogKeys.new("B").run
    end
  end
end

class LogKeys
  def initialize(cluster_name)
    cluster = Cluster.new(cluster_name).connection
    @buckets = cluster.buckets
    log_dir = File.join(ROOT,'log')
    Dir.mkdir(log_dir) unless File.exists?(log_dir)
    @log_filename = File.join(log_dir,"keys_#{cluster_name}.csv")
    @log_file = File.open(@log_filename,'w')
  end

  def run
    count = 0
    @buckets.each do |bucket|
      bucket.keys do |streaming_keys|
        streaming_keys.each do |key|
          log "/buckets/#{bucket.name}/keys/#{key}"
          count += 1
          print "." if count % 1000 == 0
        end
      end
    end
    puts "#{count} riak objects logged in #{@log_filename}"
  end

  private

  # log the object action
  def log(object_name)
    @log_file.puts object_name
  end
end
