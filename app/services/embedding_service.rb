require 'net/http'
require 'json'

class EmbeddingService
  def self.embed_many(texts)
    uri = URI("#{Rails.configuration.ollama_url}/api/embed")
    response = Net::HTTP.post(uri, { model: Rails.configuration.ollama_embedding_model, input: texts }.to_json, "Content-Type" => "application/json")
    JSON.parse(response.body).fetch("embeddings")
  end
end
