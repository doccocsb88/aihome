require 'xcodeproj'

project_path = '/Users/mac/Documents/hai/ai_home/AIHome/AIHome.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

group = project.main_group.find_subpath('AIHome/API', true)
group.set_source_tree('<group>')
group.set_path('API')

Dir.glob('/Users/mac/Documents/hai/ai_home/AIHome/AIHome/API/**/*.swift').each do |file_path|
  file_name = File.basename(file_path)
  # Find or create group based on directory structure
  rel_path = file_path.sub('/Users/mac/Documents/hai/ai_home/AIHome/AIHome/API/', '')
  parts = rel_path.split('/')
  
  current_group = group
  parts[0...-1].each do |part|
    current_group = current_group.find_subpath(part, true)
    current_group.set_source_tree('<group>')
    current_group.set_path(part)
  end
  
  # Check if file is already added
  unless current_group.files.any? { |f| f.path == file_name }
    file_reference = current_group.new_file(file_name)
    target.add_file_references([file_reference])
  end
end

project.save
puts "Added files to Xcode project successfully."
