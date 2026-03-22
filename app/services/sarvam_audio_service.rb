require "net/http"
require "json"

class SarvamAudioService
  SARVAM_API_URL = "https://api.sarvam.ai/speech-to-text"

  def self.speech_to_text(file_path, language_code: "ml-IN", model: "saarika:v2.5", mode: "transcribe", content_type: nil)
    new.speech_to_text(file_path, language_code: language_code, model: model, mode: mode, content_type: content_type)
  end

  def speech_to_text(file_path, language_code: "ml-IN", model: "saarika:v2.5", mode: "transcribe", content_type: nil)
    uri = URI(SARVAM_API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request["api-subscription-key"] = Rails.application.credentials.sarvam_api_key

    file = File.open(file_path, "rb")
    mime_type = content_type || "audio/wav"

    form_data = [
      [ "file", file, { filename: File.basename(file_path), content_type: mime_type } ],
      [ "model", model ],
      [ "mode", mode ],
      [ "language_code", language_code ]
    ]
    request.set_form(form_data, "multipart/form-data")

    response = http.request(request)
    Rails.logger.info("SarvamAudioService: status=#{response.code}, body=#{response.body}")
    body = JSON.parse(response.body)

    if body.key?("error")
      raise StandardError, body.dig("error", "message") || "Sarvam API error"
    end

    body["transcript"]
  end
end