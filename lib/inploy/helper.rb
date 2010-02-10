module Inploy
  module Helper
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
      Dir.glob("config/*.sample").each do |file|
        secure_copy file, file.gsub(".sample", '')
      end
    end

    def migrate_database
      rake "db:migrate RAILS_ENV=#{environment}"
    end

    def tasks
      `rake -T`
    end

    def install_gems
      rake "gems:install RAILS_ENV=#{environment}"
    end
  end
end
