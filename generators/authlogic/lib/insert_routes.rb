Rails::Generator::Commands::Create.class_eval do
  module MatchReplaceGroups
    def self.next_line(match,replace)
      "#{match}\n  #{replace}"
    end
    def self.route_name(name, path, conditions,route_options={})
      "map.#{name} '#{path}', :controller => '#{route_options[:controller]}', :action => '#{route_options[:action]}'#{conditions}"
    end
    def self.route_resource(resource,route_options={})
      "map.resource :#{resource}, :controller => '#{route_options[:controller]}'\n"
    end
  end
    
  def edit_file(file, matcher, replace)
    logger.alter_file "Inserting '#{replace}' into #{file}"
    curry = Proc.new{|match| MatchReplaceGroups.next_line(match, replace)}
    gsub_file( file, /(#{Regexp.escape(matcher)})/mi, &curry)
  end

  def edit_file_if_not_exists(file, matcher, replace)
    file_if_not_exists(file,replace) do 
      edit_file file, matcher, replace
    end
  end
  def file_if_not_exists(file, match_of_change, &block)
    if File.read(destination_path(file)) =~ /(#{Regexp.escape(match_of_change)})/
        logger.ident "#{file}' already contains '#{match_of_change}'"
    else
      block.call
    end 
  end
  def route_name(name, path, route_options = {})
    sentinel = 'ActionController::Routing::Routes.draw do |map|'
    conditions = ", :conditions => { :method => :#{route_options[:conditions][:method]}}" if route_options[:conditions]
    new_route_name = MatchReplaceGroups.route_name(name,path,conditions,route_options)

    unless options[:pretend]
      file_if_not_exists('config/routes.rb',new_route_name) do
        logger.route new_route_name
        edit_file 'config/routes.rb', sentinel, new_route_name
      end
    end
  end
  
  def route_resource(resource, route_options = {})
    sentinel = 'ActionController::Routing::Routes.draw do |map|'
    new_resource_name = MatchReplaceGroups.route_resource(resource,route_options).gsub("\n",'')
    logger.route new_resource_name
    unless options[:pretend]
      file_if_not_exists('config/routes.rb',new_resource_name) do
        logger.route new_resource_name
        edit_file 'config/routes.rb', sentinel, new_resource_name
      end
    end
  end

  def merge_en_locales
    require File.expand_path(File.dirname(__FILE__) + "/merge_hashes.rb")
    original_file = File.read destination_path('config/locales/en.yml')
    original_hash = YAML::load(original_file)
    our_hash = YAML::load(File.read(source_path('config/locales/en.yml')))
    new_hash = our_hash.deep_merge(original_hash)
    logger.i18n "merging en locales"
    new_file = new_hash.to_yaml
    new_file.sub!("---", '') #forgive me father, for i can has sinned
    file_if_not_exists 'config/locales/en.yml', new_file do 
      File.open(destination_path('config/locales/en.yml'), 'w') do |f|
        f << new_file
      end
    end
  end
  
end