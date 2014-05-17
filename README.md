Needy Ghost Sitemap Generator
===================

![Needy Ghost Sitemap Generator](https://github.com/jsinh/needy-ghost-sitemap/raw/master/ghost-logo.png "Needy Ghost Sitemap Generator")

##Simple sitemap generator for your Ghost blog using ruby.

---

###Works on:

 *	Windows (Windows 8.1 Pro - Tested during developement)
 *	Linux (Ubuntu - Tested in production - my blog)

---

###Requires:

*	A blog hosted on [ghost blogging platform](https://ghost.org) (duh)
*	The blog should be using MySQL as backend (this script works with MySQL only...for now)
*	[Ruby](https://www.ruby-lang.org/en/installation/) (I used verion: 1.9.3)

###Some gem information:
*	optparse
*	pp
*	mysql
*	[sitemap_generator](https://github.com/kjvarga/sitemap_generator)

---

###Usage:

**Step:** [Download](https://github.com/jsinh/needy-ghost-sitemap/archive/master.zip) the script on your machine.

	sudo apt-get update
	sudo apt-get install wget
	sudo wget https://github.com/jsinh/needy-ghost-sitemap/raw/master/needy-ghost-sitemap.rb

**Step:** Display help for usage

	needy-ghost-sitemap.rb
	OR
	needy-ghost-sitemap.rb -h
	OR
	needy-ghost-sitemap.rb --help

**Step:** Input option information

*	-h, --help					Display help options for sitemap generator.

*	-v, --verbose				Display verbose information during execution

*	-s, --ping					Specify this option if you want to ping search engines (google, bing, apple).
								Will not ping if this option is not specified

*	-d, --domain <domain-name>	Specify your Ghost blog domain name / url, E.g.: blog.jsinh.in (required)

*	-m, --mysql <hostname>		Specify your Ghost blog MySQL host name / IP Address. (required)

*	-r, --dbname <database>		Specify your Ghost blog MySQL database name. (required)

*	-u, --user <username>		Specify your Ghost blog MySQL username. (required)

*	-c, --password <password>	Specify your Ghost blog MySQL password. (required)

*	-f, --frequency <option>	Specify sitemap generated links update frequency. (required)
								Possible values: always, hourly, daily, weekly, monthly, yearly, never

*	-p, --priority <value>		Specify sitemap generated links priority. (required)
								Possible value range: 0.0 to 1.0

*	-o, --output <path>			Specify path where the newly generated sitemap should be placed


**Step:** Sample usage with ping and verbose mode

	sudo needy-ghost-sitemap.rb -d http://blog.jsinh.in -m 127.0.0.1 -r ghostdb -u ghostuser -c ghostpassword -o /var/www/ -f daily -p 0.5 -s -v

**Step:** Sample usage with ping only

	sudo needy-ghost-sitemap.rb -d http://blog.jsinh.in -m 127.0.0.1 -r ghostdb -u ghostuser -c ghostpassword -o /var/www/ -f daily -p 0.5 -s

**Step:** Sample usage with verbose only

	sudo needy-ghost-sitemap.rb -d http://blog.jsinh.in -m 127.0.0.1 -r ghostdb -u ghostuser -c ghostpassword -o /var/www/ -f daily -p 0.5 -v

**Step:** Sample usage without ping or verbose

	sudo needy-ghost-sitemap.rb -d http://blog.jsinh.in -m 127.0.0.1 -r ghostdb -u ghostuser -c ghostpassword -o /var/www/ -f daily -p 0.5