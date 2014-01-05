include_recipe "apt"
package "git"
package "imagemagick"
package "libmysqlclient-dev"
package "libpq-dev"
package "libsqlite3-dev"
package "libmagickcore-dev"
package "libmagickwand-dev"

node['redmine']['profiles'].each do |profile_name, parameters|

    redmine_destination = node['redmine']['base_path'] + "/" + profile_name
    group_name = 'www-data'

    service profile_name do
        provider Chef::Provider::Service::Upstart
        action :nothing
    end

    user profile_name do
        home redmine_destination
        system true
        gid "rbenv"
        shell "/bin/bash"
        supports :manage_home => true
    end

    ruby_version_file = redmine_destination + '/.ruby-version'

    file ruby_version_file do
        owner profile_name
        group group_name
        mode  '0644'
        action :create
        content "#{parameters[:ruby_version]}\n"
        notifies :restart, "service[#{profile_name}]"
    end

    application profile_name do
        path redmine_destination
        repository 'https://github.com/redmine/redmine.git'
        revision parameters[:redmine_version]
        symlink_before_migrate({
            "database.yml" => "config/database.yml",
            "files" => "files"
        })
        owner profile_name
        group group_name
        notifies :restart, "service[#{profile_name}]"
    end

    cookbook_file "config.ru" do
      path redmine_destination + '/current/config.ru'
      action :create_if_missing
    end

    adapter_type = nil
    case parameters[:database][:type]
    when 'mysql'
        if parameters['ruby_version'] =~ /1\.9/
            adapter_type = 'mysql2'
        else
            adapter_type = 'mysql'
        end
    when 'postgresql'
        adapter_type = 'postgresql'
    end

    file redmine_destination + "/shared/database.yml" do
        owner profile_name
        group group_name
        mode  "0644"
        action :create
        content "production:\n" +
            "  adapter: #{adapter_type}\n" +
            "  database: #{parameters[:database][:dbname]}\n" +
            "  host: localhost\n" +
            "  username: #{parameters[:database][:username]}\n" +
            "  password: #{parameters[:database][:password]}\n"
        notifies :restart, "service[#{profile_name}]"
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
        "/opt/rbenv/bin/rbenv exec gem install bundler --conservative",
        "/opt/rbenv/bin/rbenv exec bundle install --without development test",
        "/opt/rbenv/bin/rbenv exec gem install unicorn --conservative"
    ]

    commands.each do |commandLine|

        execute commandLine do
            command commandLine
            cwd redmine_destination + '/current'
            path @rbenv_path
            environment({ "RBENV_ROOT" => "/opt/rbenv", "HOME" => '/opt/rbenv'})
            user 'rbenv'
            group group_name
        end

    end

    commands = Array.new

    if parameters[:redmine_version] =~ /$2\./
        commands.push "/opt/rbenv/bin/rbenv exec rake generate_secret_token"
    else
        commands.push "/opt/rbenv/bin/rbenv exec rake generate_session_store"
    end

    commands.push "/opt/rbenv/bin/rbenv exec rake db:migrate"

    commands.each do |commandLine|

        execute commandLine do
            command commandLine
            cwd redmine_destination + '/current'
            path @rbenv_path
            environment({ "RBENV_ROOT" => "/opt/rbenv", "HOME" => redmine_destination, "RAILS_ENV" => 'production' })
            user profile_name
            group group_name
        end

    end

    template redmine_destination + '/app.rb' do
        owner   profile_name
        group   'rbenv'
        source  'app.rb.erb'
        variables({'params' => parameters[:unicorn]})
        notifies :restart, "service[#{profile_name}]"
    end

    template "/etc/init/#{profile_name}.conf" do
        owner     'root'
        group     'root'
        source    'upstart.conf.erb'
        variables({ 'profile_name' => profile_name, 'home' => redmine_destination })
        notifies :restart, "service[#{profile_name}]"
    end

    service profile_name do
        provider Chef::Provider::Service::Upstart
        action :start
    end
end
