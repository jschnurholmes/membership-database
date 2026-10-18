module ApplicationHelper

  # def link_to_function(name, *args, &block)
  #   html_options = args.extract_options!.symbolize_keys
  #
  #   function = block_given? ? update_page(&block) : args[0] || ''
  #   onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function}; return false;"
  #   href = html_options[:href] || '#'
  #
  #   content_tag(:a, name, html_options.merge(:href => href, :onclick => onclick))
  # end

  def link_to_add_fields(f, association, label, &block)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s, f: builder)
    end
    link_to('#', {:class => 'btn btn-info btn-sm add_fields', 'aria-label' => label,
                 :data => {:id => id, :fields => fields.gsub("\n", '')}}, :remote => true,
            &block)
  end

  def nav_section_active?(section)
    controller_name == section
  end

  def nav_link(label, path, section)
    active = nav_section_active?(section)
    link_to label, path, class: class_names('nav-link', active: active), aria: { current: ('page' if active) }
  end

  def tag_color_styles
    Rails.cache.fetch("tag_color_styles") do
      Tag.where.not(color: nil).order(:priority).map do |tag|
        <<~CSS
          .person-tag-#{tag.name}, .person-tag-#{tag.name} td {
            background-color: ##{tag.color};
          }
        CSS
      end.join
    end.html_safe
  end
end
