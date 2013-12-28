
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

node[:redmine_installs].each do |profile_name|

    mysql_database node[profile_name][:database][:name] do
      connection mysql_connection_info
      action :create
    end

    unless Chef::Config[:solo]
        set_unless[profile_name][:database][:password] = secure_password
    end

    mysql_database_user node[profile_name][:database][:username] do
      connection mysql_connection_info
      password node[profile_name][:database][:password]
      database_name node[profile_name][:database][:name]
      privileges [:all]
      action [:create, :grant]
    end

end