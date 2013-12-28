include_recipe "apt"
package "git"
package "imagemagick"
package "libmagickcore-dev"
package "libmagickwand-dev"

node[:redmine_installs].each do |profile_name|

  redmine_destination = node[:redmine][:base_path] + "/" + profile_name
  group_name = 'www-data'

  user profile_name do
    home redmine_destination
    system true
    gid "rbenv"
    shell "/bin/bash"
    supports :manage_home => true
  end

  #group "rbenv" do
  #  action :modify
  #  members profile_name
  #  append true
  #end

  ruby_version_file = redmine_destination + '/.ruby-version'

  file ruby_version_file do
    owner profile_name
    group group_name
    mode  '0644'
    action :create
    content "#{node[:redmine][:ruby_version]}\n"
  end

  application profile_name do
    path redmine_destination
    repository 'https://github.com/redmine/redmine.git'
    revision   node[:redmine][:version]
    symlink_before_migrate({
      "database.yml" => "config/database.yml",
      "files" => "files"
    })
    owner profile_name
    group group_name
  end

  file redmine_destination + "/shared/database.yml" do
    owner profile_name
    group group_name
    mode  "0644"
    action :create
    content "production:\n" +
            "  adapter: mysql2\n" +
            "  database: #{node[profile_name][:database][:name]}\n" +
            "  host: localhost\n" +
            "  username: #{node[profile_name][:database][:username]}\n" +
            "  password: #{node[profile_name][:database][:password]}\n"
  end

  directory redmine_destination + '/shared/files' do
    owner profile_name
    group group_name
  end

  directory redmine_destination + '/current/.bundle' do
    owner 'rbenv'
    group 'rbenv'
  end

  file redmine_destination + '/current/Gemfile.lock' do
    owner 'rbenv'
    group 'rbenv'
  end

  @rbenv_path = '/opt/rbenv/shims:/opt/rbenv/bin:/opt/rbenv/plugins/ruby_build/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games'\
  .split(':')

  commands = [
    "/opt/rbenv/bin/rbenv exec gem install bundler",
    "/opt/rbenv/bin/rbenv exec bundle install --without development test",
    "/opt/rbenv/bin/rbenv exec gem install unicorn"
  ]

  commands.each do |commandLine|

    execute commandLine do
      command commandLine
      cwd redmine_destination + '/current'
      path @rbenv_path
      environment ( { "RBENV_ROOT" => "/opt/rbenv", "HOME" => '/opt/rbenv' } )
      user 'rbenv'
      group group_name
    end

  end

  commands = [
    "/opt/rbenv/bin/rbenv exec rake generate_secret_token",
    "/opt/rbenv/bin/rbenv exec rake db:migrate"
  ]

  commands.each do |commandLine|

    execute commandLine do
      command commandLine
      cwd redmine_destination + '/current'
      path @rbenv_path
      environment ( { "RBENV_ROOT" => "/opt/rbenv", "HOME" => redmine_destination, "RAILS_ENV" => 'production' } )
      user profile_name
      group group_name
    end

  end

  template "/etc/init/#{profile_name}.conf" do
    action    :create
    owner     'root'
    group     'root'
    source    'upstart.conf.erb'
    variables ({
      'profile_name' => profile_name,
      'home' => redmine_destination
    })
  end

  service profile_name do
    provider Chef::Provider::Service::Upstart
    action :start
  end

end