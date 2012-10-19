namespace :riak do
  namespace :transfer do
    desc "Write all of the data in Cluster A into Cluster B, one object at a time."
    task :A_to_B do
      Transfer.new("A", "B").run
    end

    desc "Write all of the data in Cluster B into Cluster A, one object at a time."
    task :B_to_A do
      Transfer.new("B", "A").run
    end
  end
end

class Transfer
  def initialize(cluster_name_1, cluster_name_2)
    # first cluster
    cluster    = Cluster.new(cluster_name_1).connection
    @buckets_1 = cluster.buckets

    # second cluster
    @cluster_2 = Cluster.new(cluster_name_2).connection

    # log file
    log_dir = File.join(ROOT,'log')
    Dir.mkdir(log_dir) unless File.exists?(log_dir)
    @log_filename = File.join(log_dir,"transfer_#{cluster_name_1}_to_#{cluster_name_2}.csv")
    @log_file = File.open(@log_filename,'w')
  end

  def run
    count = 0
    @buckets_1.each do |bucket_1|
      bucket_2 = @cluster_2.bucket(bucket_1.name)
      bucket_1.keys do |streaming_keys|
        streaming_keys.each do |key|
          timer = Time.now
          object_1 = bucket_1.get(key)
          object_2 = bucket_2.new(key)
          [:key, :raw_data, :content_type, :indexes].each do |attr|
            object_2.send("#{attr.to_s}=".to_sym, object_1.send(attr))
          end
          log "/buckets/#{bucket_1.name}/keys/#{key}", Time.now - timer
          count += 1
          print "." if count % 1000 == 0
        end
      end
    end
    puts "#{count} riak objects logged in #{@log_filename}"
  end

  private

  # log the object action
  def log(object_name, time)
    @log_file.puts "#{object_name},#{time}"
  end
end
