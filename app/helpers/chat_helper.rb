module ChatHelper
  def css_class_name (message)
    return "comment" if message.system?
    return "offreco" if message.offreco?
    return "normal"
  end
end
