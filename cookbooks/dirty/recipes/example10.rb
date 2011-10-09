[ "subversion", "mercurial", "git" ].each do |pkg|  
  package pkg
end

if node["platform_version"] =~ /6\./
	puts "Hi, I am RHEL 6!"
	# now do something significant that is specific to RHEL 6
elsif node["platform_version"] =~ /5\./
	puts "Hi, I am RHEL 5"
	# now do something significant that is specific to RHEL 6
end


%w{ "iptables" "ip6tables" "bluetooth" "hplip" "isdn" "kudzu" "cups" 
"sendmail" "setroubleshoot" "avahi-daemon" }.each do |svc|
  service svc do
    action [:disable, :stop]
  end
end

execute "setenforce 0" do
	only_if "getenforce" =~ /Enforcing/
end

template "/etc/resolv.conf" do
 	source "resolv.conf.erb"
	zone_name = node["zone"]
   	zone = data_bag_item("zones", zone_name)
	variables(:nameservers => zone["nameservers"])
end

# this ntp example is stolen from here
# http://blog.afistfulofservers.net/post/3902042503/a-brief-chef-tutorial-from-concentrate
package "ntp"

template "/etc/ntp.conf" do
    source "ntp.conf.erb"
    variables( :ntp_servers => data_bag_item("zones", node["zone"])["ntp"] )
    notifies :restart, "service[ntpd]"
end

service "ntpd" do
    action[:enable,:start]
end

# users that have special sudo commands in their databag
sudoers = Array.new 
sudoers_hash = Hash.new

# set up users from databag

data_bag('users').each do |user_name|

	u = data_bag_item('users', user_name)	

	if u['id'] == "root"
		home_dir = "/root"
	else
		home_dir = "/home/#{u['id']}"
	end 

	if u['sudo_cmds'] 
		sudoers << u['id']  
	end

	puts "#{u['id']}"	

	user u['id'] do
		uid u['uid']
		gid u['gid'] || u['uid']
		shell u['shell']
		supports :manage_home => true				
	end		

	group u['id'] do
		gid u['uid']
	end

	directory "#{home_dir}/.ssh" do
	    owner u['id']
	    group u['gid'] || u['id']
	    mode "0700"
	end

	template "#{home_dir}/.ssh/authorized_keys" do
	    source "authorized_keys.erb"
	    owner u['id']
	    group u['gid'] || u['id']
	    mode "0600"
	    if u['ssh_keys']
	    	variables :ssh_keys => u['ssh_keys']
	    end
	end

end

package "sudo" do
  action :upgrade
end

ruby_block "get_sudo_cmds" do
   block do
	  sudoers.each do |username|
		sudoers_hash[ username ] = data_bag_item("users", username) 
	  end
   end
   action :create
end

template "/etc/sudoers" do
  source "sudoers.erb"
  mode 0440
  owner "root"
  group "root"
  variables(
    :sudoers => sudoers_hash 
  )
end

directory "/etc/sudoers.d" do
  mode 0440
  owner "root"
  group "root"
end 

template "/etc/sudoers.d/README" do
  mode 0440
  owner "root"
  group "root"
 source "README.sudoers"
end 

%w{'nrpe' 'nagios-plugins' 'nagios-plugins-disk'
'nagios-plugins-ping'}.each do |pkg|
	package pkg 
end

template "/etc/nagios/nrpe.cfg" do
	
end

service 'nrpe' do
   action [:enable, :start]
end



