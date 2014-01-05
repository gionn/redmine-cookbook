include_recipe "nginx::default"


node['redmine']['profiles'].each do |profile_name, parameters|

    service 'nginx' do
        action :nothing
    end

    static_files_path = node['redmine']['base_path'] + '/' + profile_name + '/current/public'

    template "nginx-host.conf" do
        path node['nginx']['dir'] + '/conf.d/' + profile_name + '.conf'
        variables({
            :hostname => parameters[:hostname],
            :upstream => parameters[:unicorn][:listen],
            :document_root => static_files_path
        })
        notifies :reload, "service[nginx]"
    end
end
