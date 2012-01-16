module Inploy
  module DSL
    module ClassMethods
      def define_callbacks(*callbacks)
        callbacks.each do |callback|
          define_method callback do |&block|
            instance_variable_set "@#{callback}", block
          end
        end
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end

    def callback(name)
      instance_variable = instance_variable_get("@#{name.to_s}")
      instance_eval(&instance_variable) unless instance_variable.nil?
    end

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
      run "#{rake_cmd} #{command}"
    end

    def rake_if_included(command)
      rake command if tasks.include?("#{rake_cmd} #{command.split[0]}")
    end

    def ruby_if_exists(file, opts)
      run "ruby #{file} #{opts[:params]}" if file_exists?(file)
    end

    def sudo_if_should
      @sudo ? 'sudo ' : ''
    end

    def using_bundler?
      file_exists?("Gemfile")
    end

    def run(command, disable_sudo = false)
      log command

      Bundler.with_clean_env do
        if disable_sudo
          Kernel.system command
        else
          Kernel.system "#{sudo_if_should}#{command}"
        end
      end
    end

    def remote_run(command)
      port_opts = port ? "-p #{port} " : ''
      hosts.each do |host|
        run "ssh #{ssh_opts} #{port_opts}#{user}@#{host} #{login_shell_wrap(command)}", true
      end
    end

    def login_shell_wrap(cmd)
      login_shell ? "\"bash -l -c '#{cmd}'\"" : "'#{cmd}'"
    end

    def secure_copy(src, dest)
      unless file_exists?(dest)
        log "cp #{src} #{dest}"
        FileUtils.cp src, dest
      end
    end

    def file_exists?(file)
      File.exists? file
    end
  end
end
