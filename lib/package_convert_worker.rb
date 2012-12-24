  require "android_constants"

class PackageConvertWorker
  def initialize(new_app_name, new_package_name, dest_dir)
    @new_app_name = new_app_name
    @new_package_name = new_package_name
    @dest_dir = dest_dir

    @target_manifest_file = "#@dest_dir/#{AndroidConstants.android_manifest}"

    @xml = REXML::Document.new(File.read @target_manifest_file)
    @manifest = @xml.root
    @original_package = @manifest.attributes["package"]
  end

  def convert
    @manifest.attributes["package"] = @new_package_name

    update_app_label

    update_application_name

    update_activity_name

    update_layout_files_custom_name_space

    update_src_to_use_new_r

    File.open(@target_manifest_file, "w") do |data|
      data << @xml
    end
  end

  def update_application_name()
    @manifest.elements.each("application") do |element|
      attribute = element.attributes.get_attribute "android:name"
      return if attribute.nil?
      element.attributes["android:name"] = full_name(@original_package, attribute.value)
    end
  end

  def update_layout_files_custom_name_space()
    Dir.glob ("#@dest_dir/res/**/*.xml") do |file|
      text = File.read(file)
      text.gsub!("http://schemas.android.com/apk/res/#@original_package", "http://schemas.android.com/apk/res/#@new_package_name")
      File.open(file, 'w') { |f| f.write(text) }
    end
  end

  def update_src_to_use_new_r()
    Dir.glob ("#@dest_dir/src/**/*.java") do |file|
      text = File.read(file)
      text.gsub!("import #@original_package.R;", "import #@new_package_name.R;")
      File.open(file, 'w') { |f| f.write(text) }
    end

    Dir.glob ("#@dest_dir/src/#{@original_package.gsub(".", "/")}/*.java") do |file|
      text = File.read(file)
      next if text.include? "import #@new_package_name.R;"
      text.gsub!("package #@original_package;", "package #@original_package;\r\nimport #@new_package_name.R;")
      p file
      File.open(file, 'w') { |f| f.write(text) }
    end
  end

  def update_activity_name()
    @manifest.elements.each("application/activity") do |element|
      p element
      activity_name = element.attributes["android:name"]
      element.attributes["android:name"] = full_name(@original_package, activity_name)
      p element.attributes["android:name"]
    end
  end

  def update_app_label()
    @manifest.elements.each("application") do |element|
      element.attributes["android:label"] = @new_app_name unless @new_app_name.nil?
    end
  end

  def full_name(package, basename)
    if basename.to_s.start_with? "." then
      package + basename
    else
      basename
    end
  end
end