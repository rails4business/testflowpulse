# config/initializers/pc_map.rb
require "yaml"

pc_map_path = Rails.root.join("config/posturacorretta/map.yml")

if File.exist?(pc_map_path)
  raw_map = YAML.load_file(pc_map_path)
  # Se usi chiavi simboliche, le converte in indifferent access
  PC_MAP = raw_map.deep_symbolize_keys.freeze
else
  Rails.logger.warn("⚠️  config/posturacorretta/map.yml non trovato — PC_MAP non caricato")
  PC_MAP = {}.freeze
end
