module ApplicationHelper
  # Renders a unified diff of two texts, line by line.
  # Removed lines shown in red, added in green, unchanged in gray.
  def lyrics_diff_html(old_text, new_text)
    old_lines = old_text.to_s.split("\n", -1)
    new_lines = new_text.to_s.split("\n", -1)

    rows = Diff::LCS.sdiff(old_lines, new_lines).flat_map do |change|
      case change.action
      when "="
        [ content_tag(:div,
            safe_join([ content_tag(:span, "  ", class: "select-none font-mono"), h(change.old_element) ]),
            class: "px-3 py-0.5 text-gray-600 font-malayalam text-sm") ]
      when "+"
        [ content_tag(:div,
            safe_join([ content_tag(:span, "+\u00a0", class: "select-none font-mono text-green-600 font-bold"), h(change.new_element) ]),
            class: "px-3 py-0.5 bg-green-100 text-green-900 font-malayalam text-sm") ]
      when "-"
        [ content_tag(:div,
            safe_join([ content_tag(:span, "\u2212\u00a0", class: "select-none font-mono text-red-500 font-bold"), h(change.old_element) ]),
            class: "px-3 py-0.5 bg-red-100 text-red-900 font-malayalam text-sm") ]
      when "!"
        [
          content_tag(:div,
            safe_join([ content_tag(:span, "\u2212\u00a0", class: "select-none font-mono text-red-500 font-bold"), h(change.old_element) ]),
            class: "px-3 py-0.5 bg-red-100 text-red-900 font-malayalam text-sm"),
          content_tag(:div,
            safe_join([ content_tag(:span, "+\u00a0", class: "select-none font-mono text-green-600 font-bold"), h(change.new_element) ]),
            class: "px-3 py-0.5 bg-green-100 text-green-900 font-malayalam text-sm")
        ]
      else
        []
      end
    end

    content_tag(:div, safe_join(rows),
      class: "border border-gray-200 rounded-md overflow-auto py-2 bg-white")
  end
end
