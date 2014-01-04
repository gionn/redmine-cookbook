Redmine Chef cookbook for massive hosting
=========================================
[![Build Status](https://travis-ci.org/gionn/redmine-cookbook.png?branch=master)](https://travis-ci.org/gionn/redmine-cookbook)

It can be used to deploy multiple versions of redmine, each one with its own dedicated system user, served by unicorn instances.

Attributes
----------

```
node['redmine']['version'] = "2.4.2"
node['redmine']['ruby_version'] = "2.0.0-p247"
node['redmine']['base_path'] = "/home"
```

Usage
-----
Declare your desired redmines to be installed under profiles, and use the proposed runlist:

```ruby
chef.json = {
    :mysql => {
        :server_root_password => "iloverandompasswordsbutthiswilldo",
        :server_repl_password => "iloverandompasswordsbutthiswilldo",
        :server_debian_password => "iloverandompasswordsbutthiswilldo"
    },
    :redmine => {
        :profiles => {
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

            },
            'redmine_secondary' => {
                :redmine_version => "1.4.2",
                :ruby_version => "1.9.3-p484",
                :database => {
                    :type => "mysql",
                    :username => "redmine_sec",
                    :password => "redmine_lka123sdkasd",
                    :dbname => "redmine_secondary"
                },
                :unicorn => {
                    :listen => 'localhost:8081',
                    :workers => 2,
                    :preload => true
                }
            }
        }
    }
}

chef.run_list = [
    "recipe[redmine::mysql]",
    "recipe[redmine::ruby]",
    "recipe[redmine::redmine]"
]

```

License and Authors
-------------------
Authors: Giovanni Toraldo
