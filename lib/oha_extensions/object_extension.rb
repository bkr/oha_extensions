module ObjectExtension
  def has_additional_functionality_in(*files)
    files.each do |file|
      require_dependency "#{name.underscore}_extensions/#{file}"
    end
  end
  
  def send_if_respond_to(method, *args)
    self.respond_to?(method) ? self.send(method, *args) : nil
  end
end