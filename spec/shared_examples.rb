shared_examples_for "local setup" do
  before :each do
    stub_tasks
  end

  it "should run migrations" do
    subject.environment = "env1"
    expect_command "rake db:migrate RAILS_ENV=#{subject.environment}"
    subject.local_setup
  end

  it "should not run migrations if it's on skip_steps" do
    subject.skip_steps = ['migrate_database']
    dont_accept_command "rake db:migrate RAILS_ENV=#{subject.environment}"
    subject.local_setup
  end

  it "should run migration after installing gems" do
    expect_command("rake gems:install RAILS_ENV=#{subject.environment}").ordered
    expect_command("rake db:migrate RAILS_ENV=#{subject.environment}").ordered
    subject.local_setup
  end

  it "should run init.sh if exists" do
    file_exists "init.sh"
    expect_command "./init.sh"
    subject.local_setup
  end

  it "should not run init.sh if doesnt exists" do
    file_doesnt_exists "init.sh"
    dont_accept_command "./init.sh"
    subject.local_setup
  end

  it "should ensure folder tmp/pids exists" do
    expect_command "mkdir -p tmp/pids"
    subject.local_setup
  end

  it "should ensure folder db exists" do
    expect_command "mkdir -p db"
    subject.local_setup
  end

  it "should copy config/*.sample to config/*" do
    path_exists "config"
    file_exists "config/database.yml.sample"
    subject.local_setup
    File.exists?("config/database.yml").should be_true
  end

  it "should not copy config/*.sample to config/* if destination file exists" do
    content = "asfasfasfe"
    path_exists "config"
    file_exists "config/database.yml", :content => content
    file_exists "config/database.yml.sample"
    subject.local_setup
    File.open("config/database.yml").read.should eql(content)
  end

  it "should install gems" do
    subject.environment = "en3"
    expect_command "rake gems:install RAILS_ENV=#{subject.environment}"
    subject.local_setup
  end

  it "should not install gems if it's on skip_steps" do
    subject.environment = "en3"
    subject.skip_steps = ['install_gems']
    dont_accept_command "rake gems:install RAILS_ENV=#{subject.environment}"
    subject.local_setup
  end

  it "should copy config/*.sample files before installing gems" do
    file_exists "config/gems.yml.sample"
    subject.stub!(:install_gems).and_raise(Exception.new)
    begin
      subject.local_setup
    rescue Exception
      File.exists?("config/gems.yml").should be_true
    end
  end

  it "should copy config/*.sample files before creating the databases" do
    file_exists "config/stars.yml.sample"
    subject.stub!(:rake).with("db:create RAILS_ENV=#{subject.environment}").and_raise(Exception.new)
    begin
      subject.local_setup
    rescue Exception
      File.exists?("config/stars.yml").should be_true
    end
  end

  it "should package the assets if asset_packager exists" do
    subject.stub!(:tasks).and_return("rake acceptance rake asset:packager:build_all rake asset:packager:create_yml")
    expect_command "rake asset:packager:build_all"
    subject.local_setup
  end

  it "should parse less files if more exists" do
    subject.stub!(:tasks).and_return("rake acceptance rake more:parse rake asset:packager:create_yml")
    expect_command "rake more:parse"
    subject.local_setup
  end

  it "should not parse less files if more doesnt exist" do
    dont_accept_command "rake more:parse"
    subject.local_setup
  end

  it "should parse less files before package assets" do
    subject.stub!(:tasks).and_return("rake more:parse rake asset:packager:build_all")
    expect_command("rake more:parse").ordered
    expect_command("rake asset:packager:build_all").ordered
    subject.local_setup
  end

  it "should create the database" do
    subject.environment = environment = "whatever"
    expect_command("rake db:create RAILS_ENV=#{environment}")
    subject.local_setup
  end
end

shared_examples_for "remote update" do
  before :each do
    @path = subject.path
  end

  it "should run inploy:local:update task in the server" do
    subject.environment = "env10"
    expect_command "ssh #{@ssh_opts} #{@user}@#{@host} 'cd #{@path}/#{@application} && rake inploy:local:update environment=#{subject.environment}'"
    subject.remote_update
  end

  it "should ssh with a configured port if exists" do
    subject.port = 3892
    expect_command "ssh #{@ssh_opts} -p 3892 #{@user}@#{@host} 'cd #{@path}/#{@application} && rake inploy:local:update environment=#{subject.environment}'"
    subject.remote_update
  end

  it "should ssh with a port even if ssh options are not specified" do
    subject.ssh_opts = nil
    subject.port = 3892
    expect_command "ssh  -p 3892 #{@user}@#{@host} 'cd #{@path}/#{@application} && rake inploy:local:update environment=#{subject.environment}'"
    subject.remote_update
  end

  it "should pass skip_steps params to local update" do
    subject.skip_steps = skip_steps = %w(migrate_dataabse gems_install)
    expect_command "ssh #{@ssh_opts} #{@user}@#{@host} 'cd #{@path}/#{@application} && rake inploy:local:update environment=#{@environment} skip_steps=#{skip_steps.join(',')}'"
    subject.remote_update
  end
end

shared_examples_for "local update" do
  before :each do
    stub_tasks
    @environment ||= "production"
  end

  it "should init submodules" do
    expect_command "git submodule update --init"
    subject.local_update
  end

  it "should run the migrations for the environment" do
    expect_command "rake db:migrate RAILS_ENV=#{subject.environment}"
    subject.local_update
  end

  it "should restart the server" do
    expect_command "touch tmp/restart.txt"
    subject.local_update
  end

  it "should clean the public/cache by default" do
    expect_command "rm -R -f public/cache"
    subject.local_update
  end

  it "should clean custom cache_dirs" do
    subject.cache_dirs = ['my/cache', 'i/love/long/cache/paths']
    subject.cache_dirs.each do |dir|
      expect_command "rm -R -f #{dir}"
    end
    subject.local_update
  end

  it "should not clean the cache if it's on skip_steps" do
    subject.skip_steps = ['clear_cache']
    subject.cache_dirs.each do |dir|
      dont_accept_command "rm -R -f #{dir}"
    end
    subject.local_update
  end

  it "should clean public assets if jammit is installed" do
    file_exists "config/assets.yml"
    expect_command "rm -R -f public/assets"
    subject.local_update
  end

  it "should not clean public assets if jammit is not installed" do
    file_doesnt_exists "config/assets.yml"
    dont_accept_command "rm -R -f public/assets"
    subject.local_update
  end

  it "should not package the assets if asset_packager exists" do
    dont_accept_command "rake asset:packager:build_all"
    subject.local_update
  end

  it "should package the assets if asset_packager exists" do
    subject.stub!(:tasks).and_return("rake acceptance rake asset:packager:build_all rake asset:packager:create_yml")
    expect_command "rake asset:packager:build_all"
    subject.local_update
  end

  it "should install gems" do
    subject.environment = "env6"
    expect_command "rake gems:install RAILS_ENV=#{subject.environment}"
    subject.local_update
  end

  it "should parse less files if more exists" do
    subject.stub!(:tasks).and_return("rake acceptance rake more:parse rake asset:packager:create_yml")
    expect_command "rake more:parse"
    subject.local_update
  end

  it "should not parse less files if more doesnt exist" do
    dont_accept_command "rake more:parse"
    subject.local_update
  end

  it "should parse less files before package assets" do
    subject.stub!(:tasks).and_return("rake more:parse rake asset:packager:build_all")
    expect_command("rake more:parse").ordered
    expect_command("rake asset:packager:build_all").ordered
    subject.local_update
  end

  it "should copy config/*.sample to config/*" do
    path_exists "config"
    file_exists "config/hosts.yml.sample"
    subject.local_update
    File.exists?("config/hosts.yml").should be_true
  end

  it "should notify hoptoad" do
    subject.environment = "env8"
    expect_command("rake hoptoad:deploy RAILS_ENV=#{subject.environment} TO=#{subject.environment} REPO=#{subject.repository} REVISION=#{`git log | head -1 | cut -d ' ' -f 2`}").ordered
    subject.local_update
  end

  it "should notify new relic rpm if exists as plugin" do
    file_exists "vendor/plugins/newrelic_rpm/bin/newrelic_cmd"
    expect_command("ruby vendor/plugins/newrelic_rpm/bin/newrelic_cmd deployments")
    subject.local_update
  end

  it "should not notify new relic rpm if doesn't exists as plugin" do
    file_doesnt_exists "vendor/plugins/newrelic_rpm/bin/newrelic_cmd"
    dont_accept_command("ruby vendor/plugins/newrelic_rpm/bin/newrelic_cmd deployments")
    subject.local_update
  end

  it "should execute before_restarting_server hook" do
    subject.before_restarting_server do
      rake "test"
    end
    expect_command("rake test").ordered
    expect_command("touch tmp/restart.txt").ordered
    subject.local_update
  end

  it "should update crontab with whenever if the file config/schedule.rb exists" do
    file_exists "config/schedule.rb"
    expect_command "whenever --update-crontab #{subject.application} --set 'environment=#{subject.environment}'"
    subject.local_update
  end

  it "should not update crontab with whenever if the file config/schedule.rb doesn't exists" do
    file_doesnt_exists "config/schedule.rb"
    dont_accept_command "whenever --update-crontab #{subject.application} --set 'environment=#{subject.environment}'"
    subject.local_update
  end

  it "should not update crontab with whenever if update_crontab is in the skip steps" do
    file_exists "config/schedule.rb"
    subject.skip_steps = %w(update_crontab)
    dont_accept_command "whenever --update-crontab #{subject.application} --set 'environment=#{subject.environment}'"
    subject.local_update
  end
end
