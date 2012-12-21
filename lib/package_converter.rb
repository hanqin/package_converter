require 'rexml/document'

class PackageConverter
  ANDROID_MANIFEST = "AndroidManifest.xml"

  def self.convert (new_package_name)
    raise "New package name should not be null or empty" if new_package_name.nil? || new_package_name.empty?
    raise "Cannot find the android manifest file" if File.exist? "./" + ANDROID_MANIFEST

    xml = File.read ANDROID_MANIFEST
    p xml
  end
end