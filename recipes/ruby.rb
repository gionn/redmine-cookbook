
case node['kernel']['machine']
  when /i.86/
    dist='deb_i386'
  when /x86_64/
    dist='deb_amd64'
  else
    dist='die'
end
apt_repository "cd-ruby" do
  uri "http://ruby-build.cloudesire.com/archive/#{dist}/"
  components ['./']
  key 'http://ruby-build.cloudesire.com/archive/gpg.key'
  action :add
end

package 'cd-rbenv'

node['redmine']['profiles'].each do |profile_name, parameters|
    package "cd-ruby-#{parameters[:ruby_version]}"
end

ruby_version_file = '/home/.ruby-version'

file ruby_version_file do
    owner 'root'
    group 'root'
    mode  '0644'
    action :create
    content "#{node['redmine']['ruby_version']}\n"
end
