# Wrap inputs/labels with a class that the design system styles (red border
# on the input, red label) and append the error message after the input itself.
# field_error_proc is invoked for each tag a form helper renders, so we detect
# the input vs the label to avoid duplicating the message.

ActionView::Base.field_error_proc = lambda do |html_tag, instance|
  helpers = ActionController::Base.helpers
  wrapped = helpers.content_tag(:div, html_tag.html_safe, class: "field_with_errors")

  if html_tag.match?(/\A<(input|select|textarea)\b/i)
    method_name = instance.instance_variable_get(:@method_name)
    messages = instance.object&.errors&.full_messages_for(method_name) || []
    if messages.any?
      wrapped += helpers.content_tag(:span, messages.to_sentence, class: "field-error")
    end
  end

  wrapped
end
