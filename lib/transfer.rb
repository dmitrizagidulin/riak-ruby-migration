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
    
    desc "Test Connections to clusters A and B"
    task :test_connections do
      puts "Cluster A config:"
      config_a = Cluster.config('A')
      puts config_a
      puts "Cluster B config:"
      config_b = Cluster.config('B')
      puts config_b
      
      puts "Connecting to Cluster A... "
      connection_a = Riak::Client.new(:nodes => [config_a])
      bucket = connection_a.bucket("test") 
      object = bucket.get_or_new("test")
      puts "OK"

      puts "Connecting to Cluster B... "
      connection_b = Riak::Client.new(:nodes => [config_b])
      bucket = connection_b.bucket("test") 
      object = bucket.get_or_new("test")
      puts "OK"
    end
    
    desc "Test xfer"
    task :xfer_test do
      
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
    max_retries = 3
    time_start = Time.now
    
    @buckets_1.each do |bucket_1|
      puts "Bucket: " + bucket_1.name
      bucket_count = 0
      bucket_2 = @cluster_2.bucket(bucket_1.name)
      bucket_1.keys do |streaming_keys|
        streaming_keys.each do |key|
          if key.empty?
            next
          end
          timer = Time.now
          
          success = false
          retry_count = 1
          
          until success or (retry_count >= max_retries) do
            begin
              object_1 = bucket_1.get(key, {:r => 2})
            rescue => e
              retry_count += 1
              next
            else
              success = true
            end
          end
          unless success
            puts "  Error getting key '" + key + "': " + e.message + " after #{retry_count} retries"
          end
          
          object_2 = object_1.clone
          object_2.bucket = bucket_2
          success = false
          retry_count = 1
          until success or (retry_count >= max_retries) do
            begin
              object_2.store({:w => 2})
            rescue => e
              retry_count += 1
              next
            else
              success = true 
              log "/buckets/#{bucket_1.name}/keys/#{key}", Time.now - timer
            end
          end
          unless success
            puts "  Error writing key '" + key + "': " + e.message + " after #{retry_count} retries"
          end
            
          count += 1
          bucket_count += 1
          puts "#{bucket_count} keys..." if bucket_count % 1000 == 0
        end
      end
      puts "#{bucket_count} keys transfered"
    end
    time_end = Time.now
    time_elapsed_total = time_end - time_start
    puts "#{count} riak objects logged to #{@log_filename}. Elapsed time: #{time_elapsed_total}"
  end

  private

  # log the object action
  def log(object_name, time)
    @log_file.puts "#{object_name},#{time}"
  end
end
