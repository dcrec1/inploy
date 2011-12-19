require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Inploy::Deploy do

  subject { Inploy::Deploy.new }

  def expect_setup_with(branch, environment = 'production', skip_steps = nil, bundler = false, app_folder = nil, bundler_opts = '--deployment --without development test cucumber')
    if branch.eql? 'master'
      checkout = ""
    else
      checkout = "&& $(git branch | grep -vq #{branch}) && git checkout -f -b #{branch} origin/#{branch}"
    end
    skip_steps_cmd = " skip_steps=#{skip_steps.join(',')}" unless skip_steps.nil?
    bundler_cmd = " && bundle install #{bundler_opts}" if bundler
    directory = app_folder.nil? ? @application : "#{@application}/#{app_folder}"
    expect_command "ssh #{@ssh_opts} #{@user}@#{@host} 'cd #{@path} && git clone --depth 1 #{@repository} #{@application} && cd #{directory} #{checkout}#{bundler_cmd} && rake inploy:local:setup RAILS_ENV=#{environment} environment=#{environment}#{skip_steps_cmd}'"
  end

  def setup(subject)
    mute subject
    stub_commands
    subject.user = @user = 'batman'
    subject.hosts = [@host = 'gothic']
    subject.path = @path = '/city'
    subject.repository = @repository = 'git://'
    subject.application = @application = "robin"
  end

  context "when executing a command" do
    before :each do
      mute subject
    end

    it "should not include sudo when not true" do
      expect_command "ls"
      subject.run "ls"
    end

    it "should include sudo when true" do
      subject.sudo = true
      expect_command "sudo ls"
      subject.run "ls"
    end

    it "should be run with a clean env" do
      Bundler.should_receive :with_clean_env
      subject.run "ls"
    end
  end

  it "should be extendable" do
    subject.template = :mouse_over_studio
    subject.remote_setup.should be_true
  end

  it "should return tasks as an string of rake tasks" do
    subject.instance_eval "def tasks_proxy; tasks; end"
    subject.tasks_proxy.should eql(`rake -T`)
  end

  it "should use master as default branch" do
    setup subject
    expect_setup_with "master"
    subject.remote_setup
  end

  it "should use production as default environment" do
    setup subject
    expect_command "rake db:migrate RAILS_ENV=production"
    subject.local_setup
  end

  it "should use production as the default environment" do
    subject.environment.should eql("production")
  end

  it "should use deploy as the default user" do
    subject.user.should eql("deploy")
  end

  it "should use /var/local/apps as the default path" do
    subject.path.should eql("/var/local/apps")
  end

  it "should use nil as the default app_folder" do
    subject.app_folder.should be_nil
  end

  context "configured" do
    before :each do
      setup subject
      subject.ssh_opts = @ssh_opts = "-A"
      subject.branch = @branch = "onions"
      subject.environment = @environment = "staging"
      subject.login_shell = @login_shell = false
    end

    context "on remote setup" do
      it "should clone the repository with the application name, checkout the branch and execute local setup" do
        expect_setup_with @branch, @environment
        subject.remote_setup
      end

      it "should not execute init.sh if doesnt exists" do
        dont_accept_command "ssh #{@user}@#{@host} 'cd #{@path}/#{@application} && ./init.sh'"
        subject.remote_setup
      end

      it "should pass skip_steps params to local setup" do
        subject.skip_steps = %w(copy_sample_files migrate_database gems_install bundle_install)
        expect_setup_with @branch, @environment, subject.skip_steps
        subject.remote_setup
      end

      it "should pass app_folder params to local setup" do
        subject.app_folder = "project"
        expect_setup_with @branch, @environment, nil, false, subject.app_folder
        subject.remote_setup
      end

      it "should execute bundle install before local setup if Gemfile exists" do
        file_exists "Gemfile"
        expect_setup_with @branch, @environment, nil, true
        subject.remote_setup
        file_doesnt_exists "Gemfile"
      end

      it "should execute bundle install with configured params" do
           file_exists "Gemfile"
           subject.bundler_opts = "--binstubs"
           expect_setup_with @branch, @environment, nil, true, nil, '--binstubs'

           subject.remote_setup
           file_doesnt_exists "Gemfile"
       end

    end

    context "on local setup" do
      it "should use staging for the environment" do
        expect_command "rake db:migrate RAILS_ENV=staging"
        subject.local_setup
      end

      it_should_behave_like "local setup"
    end

    context "on remote update" do
      it_should_behave_like "remote update"

      it "should exec the commands in all hosts" do
        subject.hosts = ['host0', 'host1', 'host2']
        3.times.each do |i|
          expect_command "ssh #{@ssh_opts} #{@user}@host#{i} 'cd #{@path}/#{@application} && rake inploy:local:update RAILS_ENV=#{@environment} environment=#{@environment}'"
        end
        subject.remote_update
      end

      it "should exec the commands in the app_folder" do
        subject.app_folder = 'project'
        expect_command "ssh #{@ssh_opts} #{@user}@#{@host} 'cd #{@path}/#{@application}/#{subject.app_folder} && rake inploy:local:update RAILS_ENV=#{@environment} environment=#{@environment}'"
        subject.remote_update
      end
     end

    context "on local update" do
      it "should pull the repository" do
        expect_command "git pull origin #{@branch}"
        subject.local_update
      end
      it "should run git submodule command from the toplevel of the working tree" do
        expect_command "cd #{@path}/#{@application} && git submodule update --init && cd #{@path}/#{@application}/#{@app_folder}"
        subject.local_update
      end

      it_should_behave_like "local update"
    end

    context "on remote install" do
      it "should execute the code from the url specified by the parameter 'from'" do
        url = 'http://fake.com/script'
        expect_command "ssh #{@ssh_opts} #{@user}@#{@host} 'bash < <(wget -O- #{url})'"
        subject.remote_install :from => url
      end
    end

    context "on remote rake" do
      it "should execute the rake task specified as parameter for the configured environment" do
        task = 'build'
        expect_command "ssh #{@ssh_opts} #{@user}@#{@host} 'cd #{@path}/#{@application} && rake #{task} RAILS_ENV=#{@environment}'"
        subject.remote_rake task
      end
      it "should execute the rake task in app_folder" do
        subject.app_folder = 'project'
        task = 'build'
        expect_command "ssh #{@ssh_opts} #{@user}@#{@host} 'cd #{@path}/#{@application}/#{subject.app_folder} && rake #{task} RAILS_ENV=#{@environment}'"
        subject.remote_rake task
      end
    end

    context "on remote reset" do
      it "should execute 'git reset --hard {:to}' in the servers" do
        commit = "fa3ed118970d8ddb0655be94b4c85d996c695476"
        expect_command "ssh #{@ssh_opts} #{@user}@#{@host} 'cd #{@path}/#{@application} && git reset --hard #{commit}'"
        subject.remote_reset :to => commit
      end

      it "should call the after_git callback" do
        subject.after_git do
          rake "test_after_git"
        end
        expect_command("rake test_after_git").ordered
        subject.update_code
      end
    end
    
    context "on code update" do
      it "should call the after_git callback" do
        subject.after_git do
          rake "test_after_git"
        end
        expect_command("rake test_after_git").ordered
        subject.update_code
      end      
    end
  end

  context "on configure" do
    it "should evaluate config/deploy.rb by default" do
      file_exists "config/deploy.rb", :content => "application = 'my_application';user = 'my_user'"
      subject.configure
      subject.user.should eql("my_user")
    end

    it "should evaluate deploy.rb case config/deploy.rb doesnt exists" do
      file_doesnt_exists "config/deploy.rb"
      file_exists "deploy.rb", :content => "application = 'my_application';user = 'my_user'"
      subject.configure
      subject.user.should eql("my_user")
    end

    it "should not raise exception case config/deploy.rb neither deploy.rb doesnt exist" do
      file_doesnt_exists "config/deploy.rb"
      file_doesnt_exists "deploy.rb"
      lambda { subject.configure }.should_not raise_error
    end

    it "should accept the old school config file 'deploy.lorem = ipsum'" do
      file_exists "config/deploy.rb", :content => "deploy.application = 'my_application';deploy.user = 'my_user'"
      subject.configure
      subject.user.should eql("my_user")
    end
  end

end
