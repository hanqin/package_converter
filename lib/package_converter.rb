require "rexml/document"
require "fileutils"
require "android_constants"
require "package_convert_worker"

class PackageConverter
  def self.convert (new_package_name, new_app_name, src_dir, dest_dir)
    raise "New package name should not be null or empty" if new_package_name.nil? || new_package_name.empty?
    raise "Cannot find the android manifest file" unless File.exist? "#{src_dir}/#{AndroidConstants.android_manifest}"

    copy_files(src_dir, dest_dir)

    PackageConvertWorker.new(new_app_name, new_package_name, dest_dir).convert
  end


  def self.copy_files(src_dir, dest_dir)
    FileUtils.rm_rf dest_dir
    FileUtils.cp_r src_dir, dest_dir
  end
end
