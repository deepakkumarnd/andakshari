module SongsHelper
    def format_song(song_text)
        if song_text.blank? || song_text.strip.blank?
            "NA"
        else
            song_text.gsub(/\r\n?/, "\n").split("\n").map { |line| h(line) }.join("<br>").html_safe
        end
    end
end
