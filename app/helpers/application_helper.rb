require 'zip/zip'

module ApplicationHelper

  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "Ruby on Rails Tutorial Sample App"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def notice
    flash[:notice]
  end

  def alert
    flash[:alert]
  end

  def set_admin_mode(value)
    session[:course_admin_mode] = value
  end

  def admin_mode?
    current_user.is_course_creator? && session[:course_admin_mode] == true
  end

  def render_course_subnav(menu_class)
    if signed_in?
      if admin_mode?
        render 'courses/courses_admin_menu', :highlight => menu_class
      else
        render 'courses/courses_menu', :highlight => menu_class
      end
    end
  end

  # if the selected_menu class name matches the menu_class
  # we make that menu item active
  def activate_menu(menu_class, selected_menu)
    class_list = menu_class
    class_list += (selected_menu == menu_class) ? " active" : ""
  end


  def unzip_file(filename, destination)
    Zip::ZipFile.open(filename) {|file|
      file.each do |f|
        f_path = File.join(destination, f.name)
        FileUtils.mkdir_p(File.dirname(f_path))
        file.extract(f, f_path) unless File.exist?(f_path)
      end
    }

    # this method will return an object file, it can cause an error for some framework.
    # added this boolean as a return value.
    true
  end
end