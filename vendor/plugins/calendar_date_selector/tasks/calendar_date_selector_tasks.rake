# desc "Explaining what the task does"
# task :calendar_date_selector do
#   # Task goes here
# end
namespace :calendar do
  namespace :assets do
    desc "Install the calendar date selector plugin assets(js/html/css)"
    task :install do
      base = File.expand_path(File.join(File.dirname(__FILE__), '..', 'assets'))
      Dir[File.join(base, 'html', '*')].each do |file|
        FileUtils.cp file, File.join(RAILS_ROOT, 'public'), :verbose => true
      end
      %w(javascripts stylesheets images).each do |asset|
        Dir[File.join(base, asset, '*')].each do |file|
          FileUtils.cp file, File.join(RAILS_ROOT, 'public', asset), :verbose => true
        end
      end
    end
  end
end