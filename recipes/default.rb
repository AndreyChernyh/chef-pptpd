package 'pptpd'

service 'pptpd' do
  supports start: true, stop: true, restart: true
  action [:enable, :start]
end

template '/etc/pptpd.conf' do
  source 'pptpd.conf.erb'
  variables localip: node['pptpd']['localip'],
            remoteip: node['pptpd']['remoteip']
  notifies :restart, 'service[pptpd]'
end

template '/etc/ppp/pptpd-options' do
  source 'pptpd-options.erb'
  variables dns: node['pptpd']['dns']
  notifies :restart, 'service[pptpd]'
end

decrypted_users = data_bag('users').map { |user| Chef::EncryptedDataBagItem.load 'users', user }

template '/etc/ppp/chap-secrets' do
  source 'chap-secrets.erb'
  variables users: decrypted_users
  notifies :restart, 'service[pptpd]'
end

template '/etc/sysctl.d/60-forward-ipv4.conf' do
  source '60-forward-ipv4.conf.erb'
  notifies :run, 'execute[reload-sysctl]'
end

execute 'reload-sysctl' do
  command 'sysctl --system'
  action :nothing
end
