require "rexml/document"
require "fileutils"

class PackageConverter
  ANDROID_MANIFEST = "AndroidManifest.xml"

  def self.convert (new_package_name, new_app_name, src_dir, dest_dir)
    raise "New package name should not be null or empty" if new_package_name.nil? || new_package_name.empty?
    raise "Cannot find the android manifest file" unless File.exist? "#{src_dir}/#{ANDROID_MANIFEST}"

    copy_files(src_dir, dest_dir)

    do_convert(new_app_name, new_package_name, dest_dir)
  end

  def self.do_convert(new_app_name, new_package_name, dest_dir)
    target_manifest = "#{dest_dir}/#{ANDROID_MANIFEST}"

    xml = REXML::Document.new(File.read target_manifest)
    manifest = xml.root
    original_package = manifest.attributes["package"]

    manifest.attributes["package"] = new_package_name

    update_app_name(manifest, new_app_name)

    update_activity_name(manifest, original_package)

    update_src_to_use_new_r(new_package_name, original_package, dest_dir)

    File.open(target_manifest, "w") do |data|
      data << xml
    end
  end

  def self.copy_files(src_dir, dest_dir)
    FileUtils.rm_rf dest_dir
    FileUtils.cp_r src_dir, dest_dir
  end

  def self.update_src_to_use_new_r(new_package_name, original_package, dest_dir)
    Dir.glob ("#{dest_dir}/src/**/*.java") do |file|
      text = File.read(file)
      text.gsub!("import #{original_package}.R;", "import #{new_package_name}.R;")
      File.open(file, 'w') { |f| f.write(text) }
    end

    Dir.glob ("#{dest_dir}/src/#{original_package.gsub(".", "/")}/*.java") do |file|
      text = File.read(file)
      next if text.include? "import #{new_package_name}.R;"
      text.gsub!("package #{original_package};", "package #{original_package};\r\nimport #{new_package_name}.R;")
      File.open(file, 'w') { |f| f.write(text) }
    end
  end

  def self.update_activity_name(manifest, original_package)
    manifest.elements.each("application/activity") do |element|
      p element
      activity_name = element.attributes["android:name"]
      element.attributes["android:name"] = activity_full_name(original_package, activity_name)
      p element.attributes["android:name"]
    end
  end

  def self.update_app_name(manifest, new_app_name)
    manifest.elements.each("application") do |element|
      element.attributes["android:label"] = new_app_name unless new_app_name.nil?
    end
  end

  def self.activity_full_name (package, basename)
    package + basename if basename.to_s.start_with? "."
  end
end