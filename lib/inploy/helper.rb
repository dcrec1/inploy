module Inploy
  module Helper
    def configuration_file
      File.open("config/deploy.rb") rescue File.open("deploy.rb") rescue nil
    end

    def skip_step?(step)
      skip_steps and skip_steps.include?(step)
    end

    def skip_steps_cmd
      " skip_steps=#{skip_steps.join(',')}" unless skip_steps.nil?
    end

    def clear_cache
      unless skip_step?('clear_cache')
        cache_dirs.each do |dir|
          run "rm -R -f #{dir}"
        end
      end
    end

    def jammit_is_installed?
      File.exists?("config/assets.yml")
    end

    def host
      hosts.first
    end

    def camelize(string)
      string.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
    end

    def application_path
      "#{path}/#{application}"
    end

    def copy_sample_files
      ["example", "sample"].each do |extension|
        Dir.glob("config/*.#{extension}").each do |file|
          secure_copy file, file.gsub(".#{extension}", '')
        end
      end
    end

    def migrate_database
      rake "db:migrate RAILS_ENV=#{environment}" unless skip_step?('migrate_database')
    end

    def tasks
      `rake -T`
    end

    def install_gems
      rake "gems:install RAILS_ENV=#{environment}" unless skip_step?('install_gems')
    end

    def update_crontab
      run "whenever --update-crontab #{application} --set 'environment=#{environment}'" if File.exists?("config/schedule.rb") unless skip_step?('update_crontab')
    end
  end
end
