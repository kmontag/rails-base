module ApplicationHelper
  def view(html_options = {}, options = {}, &block)
    partial_name = @virtual_path

    # Pass these directly to the content_tag helper
    html_options[:class] = "#{html_options[:class]} #{partial_name.split('/').map{|part| part.gsub /^_/, ''}.join '-'}"
    html_options[:'data-rc'] = partial_name.split('/').map{|s| s.gsub(/^_/, '')}.join('/')

    # Options for this method
    options = options.reverse_merge({
      tag_name: :div,
    })

    content_tag(options[:tag_name], html_options, &block)
  end
end
