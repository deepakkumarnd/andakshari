module UiHelper
  def tag_input(field_name:, current_tags: [], label: "Tags", placeholder: "Type to add tags...")
    render "shared/tag_input", field_name: field_name, current_tags: current_tags, label: label, placeholder: placeholder
  end
end
