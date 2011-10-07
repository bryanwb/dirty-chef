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
