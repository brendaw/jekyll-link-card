# frozen_string_literal: true

require "yaml"
require "digest"
require "fileutils"

module Jekyll
  module LinkCard
    module Cache
      CACHE_DIR = "tmp/cache/link-card"
      TTL = 86_400 # 24 hours in seconds

      def self.read(key)
        path = cache_path(key)
        return nil unless File.exist?(path)

        data = YAML.safe_load_file(path)
        return nil if Time.now.to_i - data["created_at"] > TTL

        data["payload"]
      rescue StandardError
        nil
      end

      def self.write(key, payload)
        FileUtils.mkdir_p(CACHE_DIR)
        data = { "created_at" => Time.now.to_i, "payload" => payload }
        File.write(cache_path(key), YAML.dump(data))
      end

      def self.cache_path(key)
        digest = Digest::SHA256.hexdigest(key)
        File.join(CACHE_DIR, "#{digest}.yml")
      end
    end
  end
end
