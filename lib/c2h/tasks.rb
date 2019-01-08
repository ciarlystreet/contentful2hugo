# encoding: utf-8

namespace :contentful do

  task :default => :download_content


  desc "Default: Download content from Contentful using contentful.yml"
  task :download_content => [:clean_content] do
    if File.exist?(".env")
      begin
        require 'dotenv'
        Dotenv.load
      rescue LoadError
      end
    end

    require 'ostruct'
    require 'c2h/mapper'

    options = OpenStruct.new
    options.debug = true
    options.verbose = true
    options.configfile = "contentful.yml"

    mapper = C2H::Mapper.new(options)
    mapper.run
  end


  desc "Clean contentful content"
  task :clean_content do
    puts "WARNING: This will remove all unversioned content files!!!"
    sh "git clean -f content"
  end
end
