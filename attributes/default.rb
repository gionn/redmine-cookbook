
default[:redmine][:profiles] = {
    'redmine_default' => {
        :redmine_version => "2.4.2",
        :ruby_version => "2.0.0-p247",
        :database => {
            :type => "mysql",
            :username => "redmine_default",
            :password => "redmine_default",
            :dbname => "redmine_default"
        },
        :unicorn => {
            :listen => 'localhost:8080',
            :workers => 2,
            :preload => true
        }
    }
}

default[:redmine][:version] = "2.4.2"
default[:redmine][:ruby_version] = "2.0.0-p247"
default[:redmine][:base_path] = "/home"

override['mysql']['remove_anonymous_users'] = true
override['mysql']['remove_test_database'] = true

