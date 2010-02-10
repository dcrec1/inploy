module Inploy
  module DSL
    def create_folder(path)
      run "mkdir -p #{path}"
    end

    def create_folders(*folders)
      folders.each { |folder| create_folder folder }
    end

    def load_module(filename)
      require "inploy/#{filename}"
      extend eval(filename.split("/").map { |word| camelize(word) }.join("::"))
    end

    def log(command)
      puts "Inploy => #{command}"
    end

    def rake(command)
      run "rake #{command}"
    end

    def rake_if_included(command)
      rake command if tasks.include?("rake #{command.split[0]}")
    end

    def ruby_if_exists(file, opts)
      run "ruby #{file} #{opts[:params]}" if File.exists?(file)
    end

    def run(command, disable_sudo = false)
      log command

      if disable_sudo
        Kernel.system command
      else
        Kernel.system "#{@sudo}#{command}"
      end
    end

    def remote_run(command)
      ssh_opts.concat " -p #{port}" if ssh_opts and port
      hosts.each do |host|
        run "ssh #{ssh_opts} #{user}@#{host} '#{command}'", true
      end
    end

    def secure_copy(src, dest)
      unless File.exists?(dest)
        log "mv #{src} #{dest}"
        FileUtils.cp src, dest
      end
    end
  end
end
