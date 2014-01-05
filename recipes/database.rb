
unless Chef::Config[:solo]
    include Opscode::OpenSSL::Password
end

include_recipe "apt"

node['redmine']['profiles'].each do |profile_name, parameters|

    unless Chef::Config[:solo]
        set_unless['redmine']['profiles'][profile_name]['database']['password'] = secure_password
    end

    case parameters[:database][:type]
    when 'mysql'
        include_recipe "mysql::ruby"
        include_recipe "mysql::server"
        connection_info = {
            :host     => 'localhost',
            :username => 'root',
            :password => node['mysql']['server_root_password']
        }
        mysql_database parameters[:database][:dbname] do
            connection connection_info
            action :create
        end
        mysql_database_user parameters[:database][:username] do
            connection connection_info
            password parameters[:database][:password]
            database_name parameters[:database][:dbname]
            privileges [:all]
            action [:create, :grant]
        end
    when 'postgresql'
        include_recipe "postgresql::ruby"
        include_recipe "postgresql::server"
        connection_info = {
            :host     => '127.0.0.1',
            :port     => node['postgresql']['config']['port'],
            :username => 'postgres',
            :password => node['postgresql']['password']['postgres']
        }
        postgresql_database parameters[:database][:dbname] do
            connection connection_info
            action :create
        end
        postgresql_database_user parameters[:database][:username] do
            connection connection_info
            password parameters[:database][:password]
            database_name parameters[:database][:dbname]
            privileges [:all]
            action [:create, :grant]
        end
    end
end
