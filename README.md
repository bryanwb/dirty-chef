This is a stupid, simple Chef tutorial for Lazy Fry Cooks (like me)

This tutorial teaches you exactly the wrong way to use chef cookbooks. 

On the positive side, this tutorial should give you some instant gratification
and a sense of how powerful chef is.

Steps:

== Installation ==
1. install Chef
start here:
http://wiki.opscode.com/display/chef/Bootstrap+Chef+RubyGems+Installation

on RHEL 6
$ yum -y install ruby.x86_64 ruby-devel.x86_64 ruby-ri.x86_64 ruby-rdoc.x86_64 ruby-libs.x86_64 git gcc gcc-c++ automake autoconf make
$ yum -y install rubygems
$ gem install chef ohai

on RHEL 5 it is much more complicated, see the installation link on the opscode wiki

clone this repo into somewhere on your system, I recommend /opt

Next, edit solo.rb. The values in this file require __absolute__ paths. I use /opt but if you clone this repository anywhere else
make sure you change all these paths accordingly.

I am going to use chef-solo for the purpose of the tutorial. Chef-solo simply means running chef with out connecting to central chef server that provides you with cookbooks and some other functionality. Chef-server is awesome but currently a pain in the butt to set up.  

== Sanity check ==

Run the following command

$ ohai | less

This shows you all the info that chef knows about your system. You can do reasoning in your recipes based on these values.

== Start Cooking ==

Here is a stupid hello world 

$ chef-solo -c solo.rb -j node.json

Now let us do something more significant.

You can use chef to declare "resources" in this case a package
$ chef-solo -c solo.rb -j example1.json

Here is an example of installing multiple packages

$ chef-solo -c solo.rb -j example2.json
What is that syntax of the configuration language? Why it is pure ruby. If you like perl, you will like ruby
as it is the lovechild of perl and smalltalk. 

here is a good quick reference http://wiki.opscode.com/display/chef/Just+Enough+Ruby+for+Chef

You still are not impressed? True you could do all these things in a kickstart more easily and without having to 
go to so much trouble. There are several reasons chef is better than kickstart.

1. You can use chef to maintain the state of your server while you can only use kickstart to initially set up your server.

Once you install your server from a kickstart, you cannot rerun it w/out reformatting it. Chef on the other hand is "idempotent"
Meaning it has the same effect whether run once or 100 times. Say for some reason subversion is removed from your machine. The above chef recipe
will reinstall it w/out needing your intervention.

2. You can seamlessly handle different platform versions. You can write one recipe that handles both RHEL 5 and RHEL 6 by doing reasoning on node attributes.

Maybe you are like me and love nothing better than a good REPL (Read-Eval Print Loop), i.e. console. Chef comes with an awesome REPL, shef. Let us use it to
play node attributes

[root@woof-chef recipes]# shef
loading configuration: none (standalone shef session)
Session type: standalone
Ohai2u root@woof-chef!
chef > if node["platform_version"] =~ /6\./
chef ?> puts "hi rhel 6!"
chef ?> end
hi rhel 6!

[ type ctl-D to exit ]

In shef, you have access to all the node attributes and cookbooks on your system. Now let us put the same logic in a recipe

$ chef-solo -c solo.rb -j example3.json

# To manage user passwords, you have to enable an additional repository
rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-5.noarch.rpm
yum install -y ruby-shadow 

how to encrypt passwd for use in recipe
openssl passwd -1 "theplaintextpassword"
