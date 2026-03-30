class FeatureFlags
  CONFIG = YAML.load_file(Rails.root.join("config/features.yml")).freeze

  def self.enabled?(feature)
    CONFIG.dig(feature.to_s, Rails.env, "enabled") == true
  end
end
