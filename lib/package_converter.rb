require "rexml/document"
require "fileutils"

class PackageConverter
  ANDROID_MANIFEST = "AndroidManifest.xml"

  def self.convert (new_package_name, new_app_name, src_dir, dest_dir)
    raise "New package name should not be null or empty" if new_package_name.nil? || new_package_name.empty?
    raise "Cannot find the android manifest file" unless File.exist? "#{src_dir}/#{ANDROID_MANIFEST}"

    copy_files(src_dir, dest_dir)

    new PackageConvertWorker(new_app_name, new_package_name, dest_dir).convert
  end

end
