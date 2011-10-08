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
