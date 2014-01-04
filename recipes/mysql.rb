
mysql_connection_info = {
  :host     => 'localhost',
  :username => 'root',
  :password => node['mysql']['server_root_password']
}
unless Chef::Config[:solo]
    include Opscode::OpenSSL::Password
end

include_recipe "apt"
include_recipe "mysql::server"
include_recipe "mysql::ruby"

node['redmine']['profiles'].each do |profile_name, parameters|

    mysql_database parameters[:database][:dbname] do
      connection mysql_connection_info
      action :create
    end

    unless Chef::Config[:solo]
        set_unless['redmine']['profiles'][profile_name]['database']['password'] = secure_password
    end

    mysql_database_user parameters[:database][:username] do
      connection mysql_connection_info
      password parameters[:database][:password]
      database_name parameters[:database][:dbname]
      privileges [:all]
      action [:create, :grant]
    end

end
