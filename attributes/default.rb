default[:redmine_installs] = [ 'redmine_default' ]
default[:redmine][:version] = "2.4.2"
default[:redmine][:ruby_version] = "2.0.0-p247"
default[:redmine][:base_path] = "/home"

override['mysql']['remove_anonymous_users'] = true
override['mysql']['remove_test_database'] = true