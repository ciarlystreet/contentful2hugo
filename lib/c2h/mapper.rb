# encoding: utf-8
require 'contentful'
require 'yaml'
require 'open-uri'
require 'fileutils'
require 'time'
require 'erb'

module C2H
  class Mapper

    attr_accessor :options

    def initialize(options)
      options.debug = false
      @options = options
    end

    def run
      #Load config file
      config = YAML.load(ERB.new(File.read(options.configfile)).result)
      puts "Config:\n  #{config.inspect}" if options.debug

      # Check if the content_dir is set in configfile
      raise "content_dir not set in config file" if config['content_dir']== '' || config['content_dir'] == nil

      # Check if the access_token is set in configfile
      raise "access_token not set in config file" if config['access_token']== '' || config['access_token'] == nil

      # Content dir location
      content_dir = "#{File.dirname(options.configfile)}/#{config.fetch('content_dir', 'content')}"

      # Check if content directory exists
      raise "Content directory not found - #{content_dir}" if !File.directory?(content_dir)

      if config['download_images'] == 'true' ||  config['download_images'] == true
        # Check if the image_dir is set in configfile
        raise "image_dir not set in config file" if config['image_dir']== '' || config['image_dir'] == nil

        #Image dir location
        image_dir = "#{File.dirname(options.configfile)}/#{config['image_dir']}"

        # Check if image directory exists
        raise "Image directory not found - #{image_dir}" if !File.directory?(image_dir)

        # Image download list (no double downloads for the same img)
        downloaded_images = {}
      end

      # Process spaces
      config["spaces"].each do |space_key, content_types|
        client_config = {
          access_token: config['access_token'],
          space: space_key,
        }
        puts "Client config:\n  #{client_config.inspect}" if options.debug
        client = Contentful::Client.new(client_config)
        begin
          content_types.each do |content_type, content_type_config|

            puts "Getting #{space_key} => #{content_type}" if options.verbose

            # Check if section is set
            raise "No section set for this content type - #{content_type}" if content_type_config['section'] == '' || content_type_config['section'] == nil

            #section content directory Location
            section_content_dir = "#{content_dir}/#{content_type_config['section']}"

              # Process all languages
            config['locales'].split(',').each do |locale|
              puts "############  #{locale}"
              # Process entries
              query = {content_type: content_type, locale: "#{locale}"}
              puts "Running query:\n  #{query.inspect}" if options.debug
              entries = client.entries(query)
              puts "entries  #{entries}" if options.debug
              entries.each do |entry|
                puts "  #{entry.fields.inspect}" if options.debug

                # Reset variables
                content = ''
                fields = {}
                filename = ''

                def process_field(entry, mapping)
                  if mapping.include?('.')
                    # access nested data
                    sub_field, *rest = mapping.split('.')
                    process_field(entry.fields.fetch(sub_field.to_sym), rest.join('.'))
                  elsif entry.kind_of?(Array)
                    entry.map { |elt|
                      elt.fields.fetch(mapping.to_sym)
                    }
                  else
                    entry.fields.fetch(mapping.to_sym)
                  end
                end

                # Process field in the entry.
                entry.fields.each do |key, value|
                  key = key[0,key.length] #remove ':' before keys
                  if content_type_config['filename'] != nil && content_type_config['filename'] != '' && key == content_type_config['filename']
                    filename = value
                  end
                  if key == content_type_config['content']
                    content = value
                  else
                    fields[key] = process_field(entry, content_type_config.fetch(key, key))
                  end
                end

                # If no filename field is found, the entry id is used
                if filename == ''
                  filename = "#{entry.id}.#{locale}" 
                else
                  filename = "#{filename}.#{locale}"
                end

                # Path to content-file
                fullpath = "#{section_content_dir}/#{filename}.md"
                puts "################## filename #{filename}"

                if File.file?(fullpath) && File.new(fullpath).mtime > Time.parse(entry.sys[:updatedAt].to_s)
                  puts "  #{fullpath}: UpToDate -> skip" if options.verbose
                else

                  if config['download_images'] == 'true' || config['download_images'] == true
                    # Section image directory location
                    section_image_dir = "#{image_dir}/#{content_type_config['section']}"

                    # Entry image directory location
                    entry_image_dir = "#{section_image_dir}/#{filename}"

                    # Get images from content
                    content.scan(/!\[[^\]]*\]\(([A-Za-z0-9_\/\.\-]*\/)([A-Za-z0-9_\.\-]+)\)/).each do |url, name|

                      puts "    #{entry_image_dir}/#{name}" if options.verbose

                      # Create sub directory for section if it doesn't exist
                      if !File.directory?(section_image_dir)
                        Dir.mkdir(section_image_dir)
                      end

                      # Create sub directory for entry if it doesn't exist
                      if !File.directory?(entry_image_dir)
                        Dir.mkdir(entry_image_dir)
                      end

                      full_url = "http:#{url}#{name}"
                      full_path = "#{entry_image_dir}/#{name}"

                      # Image isn't downloaded yet
                      if downloaded_images[full_url] == nil
                        begin
                          # Download image & write to file
                          File.write(full_path, open(full_url).read)
                          if downloaded_images[full_url] == nil
                            downloaded_images[full_url] = {}
                          end
                          downloaded_images[full_url][full_path] = true;
                        rescue => e
                          puts (options.verbose ? "      #{e.message}": "#{e.message}")

                          downloaded_images[full_url][full_path] = false;
                        end
                      else
                        # The image was downloaded but to an other location
                        if downloaded_images[full_url][full_path] == nil
                          # Search already downloaded copy
                          prev_full_url = nil
                          downloaded_images[full_url].each do |u|
                            prev_full_url = u
                            next
                          end
                          begin
                            # Copy prev downloaded copy
                            FileUtils.cp(prev_full_url, full_url);
                            downloaded_images[full_url][full_path] = true;
                          rescue => e
                            puts (options.verbose ? "      #{e.message}": "#{e.message}")
                            downloaded_images[full_url][full_path] = false;
                          end
                        end
                      end
                      # Replace URL in content, remove static dir if present
                      content = content.sub("#{url}#{name}", full_path.sub(/.*static/,''))
                    end
                  end

                  # Create sub directory for section if it doesn't exist
                  if !File.directory?(section_content_dir)
                    Dir.mkdir(section_content_dir)
                  end

                  # Write file
                  File.open(fullpath, 'w') do |file|
                    file.write(fields.to_yaml)
                    file.write("---\n")
                    file.write(content)
                  end
                end
              end
            end
          end
        rescue StandardError
          raise
        end
      end
    end

  end
end