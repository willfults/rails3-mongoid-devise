module DeviseHelper
  def display_devise_error_messages
    flash_alerts = []
    
    if ! flash.empty?
      flash_alerts.push(flash[:error]) if flash[:error]
      flash_alerts.push(flash[:alert]) if flash[:alert]
      flash_alerts.push(flash[:notice]) if flash[:notice]
      error_key = 'devise.failure.invalid'
    end
        
    return if resource.errors.empty? && flash_alerts.empty?
    
    errors = resource.errors.empty? ? flash_alerts : resource.errors.full_messages
    messages = errors.map { |msg| content_tag(:li, msg) }.join
    
    html = <<-HTML
      <div id="error_explanation" class="alert-error">
        <ul>#{messages}</ul>
      </div>
      HTML

    html.html_safe
  end

end