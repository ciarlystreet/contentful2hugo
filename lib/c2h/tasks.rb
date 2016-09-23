# encoding: utf-8

namespace :contentful do

  task :default => :download_content


  desc "Default: Download content from Contentful"
  task :download_content => [:clean_content] do
    if File.exist?(".env")
      begin
        require 'dotenv'
        Dotenv.load
      rescue LoadError
      end
    end
    sh "bundle exec c2h --conf contentful.yml --verbose --debug"
  end


  desc "Clean contentful content"
  task :clean_content do
    puts "WARNING: This will remove all unversioned content files!!!"
    sh "git clean -f content"
  end
end
