require 'rexml/document'

class PackageConverter
  ANDROID_MANIFEST = "AndroidManifest.xml"

  def self.convert (new_package_name)
    raise "New package name should not be null or empty" if new_package_name.nil? || new_package_name.empty?
    raise "Cannot find the android manifest file" unless File.exist? ANDROID_MANIFEST

    xml = REXML::Document.new(File.read ANDROID_MANIFEST)
    manifest = xml.root
    original_package = manifest.attributes["package"]

    manifest.attributes["package"] = new_package_name

    manifest.elements.each("application/activity") do |element|
      p element
      activity_name = element.attributes["android:name"]
      element.attributes["android:name"] = activity_full_name(original_package, activity_name)
      p element.attributes["android:name"]
    end

    Dir.glob ("src/**/*.java") do |file|
      text = File.read(file)
      text.gsub!("import #{original_package}.R;", "import #{new_package_name}.R;")
      File.open(file, 'w') { |f| f.write(text) }
    end

    Dir.glob ("src/#{original_package.gsub(".", "/")}/*.java") do |file|
      text = File.read(file)
      next if text.include? "import #{new_package_name}.R;"
      text.gsub!("package #{original_package};", "package #{original_package};\r\nimport #{new_package_name}.R;")
      File.open(file, 'w') { |f| f.write(text) }
    end

    File.open(ANDROID_MANIFEST, "w") do |data|
      data << xml
    end
  end

  def self.activity_full_name (package, basename)
    package + basename if basename.to_s.start_with? "."
  end
end