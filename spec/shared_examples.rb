shared_examples_for "remote update" do
  before :each do
    @path = subject.path
  end
  
  it "should run inploy:local:update task in the server" do
    expect_command "ssh #{@user}@#{@host} 'cd #{@path}/#{@application} && rake inploy:local:update'"
    subject.remote_update
  end
end

shared_examples_for "local update" do
  before :each do
    stub_tasks
  end
  
  it "should run the migrations for production" do
    expect_command "rake db:migrate RAILS_ENV=production"
    subject.local_update
  end

  it "should restart the server" do
    expect_command "touch tmp/restart.txt"
    subject.local_update
  end

  it "should clean the public cache" do
    expect_command "rm -R -f public/cache"
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
    expect_command "rake gems:install"
    subject.local_update
  end
end