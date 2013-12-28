
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
package "cd-ruby-#{node[:redmine][:ruby_version]}"
