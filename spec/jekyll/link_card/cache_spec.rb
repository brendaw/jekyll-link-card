require "spec_helper"
require "jekyll/link_card/cache"

RSpec.describe Jekyll::LinkCard::Cache do
  let(:cache_dir) { "tmp/cache/link-card-test" }

  before do
    stub_const("Jekyll::LinkCard::Cache::CACHE_DIR", cache_dir)
    FileUtils.rm_rf(cache_dir)
  end

  after do
    FileUtils.rm_rf(cache_dir)
  end

  describe ".write" do
    it "creates cache file with payload" do
      described_class.write("https://example.com", { "title" => "Test" })

      files = Dir.glob("#{cache_dir}/*.yml")
      expect(files.length).to eq(1)

      data = YAML.safe_load_file(files.first)
      expect(data["payload"]).to eq({ "title" => "Test" })
      expect(data["created_at"]).to be_within(2).of(Time.now.to_i)
    end

    it "creates cache directory if missing" do
      expect(Dir.exist?(cache_dir)).to be false

      described_class.write("https://example.com", {})

      expect(Dir.exist?(cache_dir)).to be true
    end
  end

  describe ".read" do
    it "returns cached payload on hit" do
      described_class.write("https://example.com", { "title" => "Cached" })

      result = described_class.read("https://example.com")

      expect(result).to eq({ "title" => "Cached" })
    end

    it "returns nil on miss" do
      expect(described_class.read("https://nonexistent.com")).to be_nil
    end

    it "returns nil when cache is expired" do
      path = described_class.cache_path("https://expired.com")
      FileUtils.mkdir_p(cache_dir)
      data = { "created_at" => Time.now.to_i - 90_000, "payload" => { "old" => true } }
      File.write(path, YAML.dump(data))

      expect(described_class.read("https://expired.com")).to be_nil
    end

    it "returns nil on corrupted file" do
      path = described_class.cache_path("https://corrupted.com")
      FileUtils.mkdir_p(cache_dir)
      File.write(path, "not valid yaml: [[")

      expect(described_class.read("https://corrupted.com")).to be_nil
    end
  end

  describe ".cache_path" do
    it "returns deterministic path for same key" do
      path1 = described_class.cache_path("https://example.com")
      path2 = described_class.cache_path("https://example.com")

      expect(path1).to eq(path2)
    end

    it "returns different paths for different keys" do
      path1 = described_class.cache_path("https://example.com")
      path2 = described_class.cache_path("https://other.com")

      expect(path1).not_to eq(path2)
    end

    it "places files in cache directory" do
      path = described_class.cache_path("https://example.com")

      expect(path).to start_with(cache_dir)
      expect(path).to end_with(".yml")
    end
  end
end
