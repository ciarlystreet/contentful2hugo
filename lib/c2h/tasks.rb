# encoding: utf-8

namespace :contentful do

  task :default => :download_content

  begin
    require 'dotenv/task'
  rescue LoadError
    desc "Dotenv stub if it isn't installed"
    task :dotenv
  end

  desc "Default: Download content from Contentful"
  task :download_content => [:dotenv, :clean_content] do
    sh "bundle exec c2h --conf contentful.yml --verbose --debug"
  end


  desc "Clean contentful content"
  task :clean_content do
    puts "WARNING: This will remove all unversioned content files!!!"
    sh "git clean -f content"
  end
end
