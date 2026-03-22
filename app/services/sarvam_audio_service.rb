require "net/http"
require "json"

class SarvamAudioService
  SARVAM_API_URL = "https://api.sarvam.ai/speech-to-text"

  def self.speech_to_text(file_path, language_code: "ml-IN", model: "saarika:v2", mode: "formal")
    new.speech_to_text(file_path, language_code: language_code, model: model, mode: mode)
  end

  def speech_to_text(file_path, language_code: "ml-IN", model: "saarika:v2", mode: "formal")
    uri = URI(SARVAM_API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request["api-subscription-key"] = Rails.application.credentials.sarvam_api_key

    form_data = [
      [ "file", File.open(file_path, "rb") ],
      [ "model", model ],
      [ "mode", mode ],
      [ "language_code", language_code ]
    ]
    request.set_form(form_data, "multipart/form-data")

    response = http.request(request)
    body = JSON.parse(response.body)

    if body.key?("error")
      raise StandardError, body.dig("error", "message") || "Sarvam API error"
    end

    body["transcript"]
  end
end
