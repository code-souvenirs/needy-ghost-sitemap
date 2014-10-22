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
	sudo apt-get install ruby ruby-dev
	sudo apt-get install libmysqlclient-dev libmysqlclient18 (Updated on 20th Oct 2014 - Required due to error installing MySQL gem)
	sudo apt-get install wget
	sudo wget https://github.com/jsinh/needy-ghost-sitemap/raw/master/needy-ghost-sitemap.rb
	sudo chown root:root needy-ghost-sitemap.rb
	sudo chmod +x needy-ghost-sitemap.rb

**Step:** Display help for usage

	needy-ghost-sitemap.rb
	OR
	needy-ghost-sitemap.rb -h
	OR
	needy-ghost-sitemap.rb --help

**Step:** Input option information

*	-h, --help					Display help options for sitemap generator.

*	-w, --version				Displays scripts version information

*	-v, --verbose				Display verbose information during execution.

*	-s, --ping					Specify this option if you want to ping search engines (google, bing, apple).
								Will not ping if this option is not specified.

*	-d, --domain <domain-name>	Specify your Ghost blog domain name / url, E.g.: blog.jsinh.in (required)

*	-m, --mysql <hostname>		Specify your Ghost blog MySQL host name / IP Address. (required)

*	-r, --dbname <database>		Specify your Ghost blog MySQL database name. (required)

*	-u, --user <username>		Specify your Ghost blog MySQL username. (required)

*	-c, --password <password>	Specify your Ghost blog MySQL password. (required)

*	-f, --frequency <option>	Specify sitemap generated links update frequency. (required)
								Possible values: always, hourly, daily, weekly, monthly, yearly, never

*	-p, --priority <value>		Specify sitemap generated links priority. (required)
								Possible value range: 0.0 to 1.0

*	-o, --output <path>			Specify path where the newly generated sitemap should be placed. Do not include sitemap file name.


**Step:** Sample usage with ping and verbose mode

	sudo needy-ghost-sitemap.rb -d http://blog.jsinh.in -m 127.0.0.1 -r ghostdb -u ghostuser -c ghostpassword -o /var/www/ -f daily -p 0.5 -s -v

**Step:** Sample usage with ping only

	sudo needy-ghost-sitemap.rb -d http://blog.jsinh.in -m 127.0.0.1 -r ghostdb -u ghostuser -c ghostpassword -o /var/www/ -f daily -p 0.5 -s

**Step:** Sample usage with verbose only

	sudo needy-ghost-sitemap.rb -d http://blog.jsinh.in -m 127.0.0.1 -r ghostdb -u ghostuser -c ghostpassword -o /var/www/ -f daily -p 0.5 -v

**Step:** Sample usage without ping or verbose

	sudo needy-ghost-sitemap.rb -d http://blog.jsinh.in -m 127.0.0.1 -r ghostdb -u ghostuser -c ghostpassword -o /var/www/ -f daily -p 0.5

---

###Scheduled execution setup:

I am using CRONTAB for scheduled execution of this script.

**Step:** Install CRONTAB

	sudo apt-get update
	sudo apt-get gnome-schedule

**Step:** Edit crontab and add this script for execution.

	sudo crontab -e

Add the following at end of the file:
	
	* */6 * * * ruby <full-path-to-needy-ghost-sitemap.rb> -d <domainame> -m <mysqlhostname> -r <dbname> -u <username> -c <password> -o <output-file-path> -f daily -p 0.9 -s

This executes the script (with ping and no verbose) every 6 hours.

You can collect execution information from CRONTAB execution schedule by using following command instead of the above:

	* */6 * * * ruby <full-path-to-needy-ghost-sitemap.rb> -d <domainame> -m <mysqlhostname> -r <dbname> -u <username> -c <password> -o <output-file-path> -f daily -p 0.9 -s >> <path-to-log-filename> 2>&1

---

###Flashback:

Currently Ghost does not provide out-of-the-box support for sitemap generation. So first thing I do is search google:

Option 1:	[Generate sitemap using SHELL script](http://ghost.centminmod.com/ghost-sitemap-generator/) (I could not get my head around and make it work with my installation, brain-freeze SHELL script for me)

Option 2:	[Generate sitemap using RUBY script with MySQL](https://github.com/mmornati/ghost-sitemap-generator) (I used this initially, worked well but not complete)

Option 3:	Next search was "[Generate sitemap online](http://www.xml-sitemaps.com/)". This generated the best (with all links included - sitemap but has a limitation of generating 500 links for free user)

So option 1 didn't work for me all at, option 2 generated site map for index page (with pagination) and posts only and no tag links generated and option 3 had a limitation, plus I had to generate manually and upload everytime.

---

###Credits:

Option 2 was the best one I can rely on, so I took the idea and decided to groom it to my needs.

Base idea and [original code](https://github.com/mmornati/ghost-sitemap-generator) credits to : [Macro Mornati](http://blog.mornati.net/optimize-ghost-for-seo-sitemap-generator/), thanks !!

Life became cool with [Sitemap_generator](https://github.com/kjvarga/sitemap_generator) gem in ruby, thanks !!

---

###Why not use option 2 and do something else?

Here is why (no offense, please)

*	Links for tags not generated.
*	Sitemap generated in from of *.xml file, what if my blog grows to 500 articles and 5000 tags, I needed *.tar.gz.
*	It used raw XML namespace and schema references, will break or might not be valid if the sitemap protocol changes. Using sitemap_generator will save me from those tidious work, those ninga's will probably take care of it.
*	Added more validation and more readable verbose logs.

---

###License

This work is [licensed](https://github.com/jsinh/needy-ghost-sitemap/raw/master/LICENSE) under:

The MIT License (MIT)
Copyright (c) 2014 Jaspalsinh Chauhan

---

Note: I am a C# / .NET guy and this was my first very piece of code written in RUBY. Feel free to poke me for any changes you might need (if I can figure that out) or feel my code is hilarious, share the joke :D
