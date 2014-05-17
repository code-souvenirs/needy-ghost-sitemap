#!/usr/bin/ruby

require 'rubygems'
require 'optparse'
require 'pp'
require 'mysql'
require 'sitemap_generator'
require 'uri'

# => Start block
begin
	startoptions = {}

	optparse = OptionParser.new do |options|
		# Set banner for start-up options
		options.banner = "\nGenerate needy sitemaps for your Ghost blog. Usage: => ruby needy_sitemap.rb [options]"

		# Set help option
		options.on('-h', '--help', "Display help options for sitemap generator.") do
			puts options
			exit
		end

		options.on('-w','--version', "Displays scripts version information") do
			puts "Version: 1.2"
			exit
		end

		# Set verbosity option
		options.on( '-v', '--verbose', 'Display verbose information during execution') do |verbose|
			startoptions[:verbose] = verbose
		end

		# Set Ping google option
		options.on('-s', '--ping', 'Specify this option if you want to ping search engines (google, bing, apple).
				     Will not ping if this option is not specified') do |ping|
			startoptions[:ping] = ping
		end

		# Set domain name option
		options.on( '-d', '--domain <domain-name>', 'Specify your Ghost blog domain name / url, E.g.: blog.jsinh.in (required)') do |domain|
			startoptions[:domain] = domain
		end

		# Set MySQL host name option
		options.on('-m', '--mysql <hostname>', 'Specify your Ghost blog MySQL host name / IP Address. (required)') do |host|
			startoptions[:host] = host
		end

		# Set MySQL database name option
		options.on('-r', '--dbname <database>', 'Specify your Ghost blog MySQL database name. (required)') do |dbname|
			startoptions[:dbname] = dbname
		end

		# Set MySQL username option
		options.on('-u', '--user <username>', 'Specify your Ghost blog MySQL username. (required)') do |user|
			startoptions[:user] = user
		end

		# Set MySQL password option
		options.on('-c', '--password <password>', 'Specify your Ghost blog MySQL password. (required)') do |password|
			startoptions[:password] = password
		end

		# Set sitemap link change frequency option
		options.on( '-f', '--frequency <option>', 'Specify sitemap generated links update frequency. (required)
				     Possible values: always, hourly, daily, weekly, monthly, yearly, never' ) do |frequency|
           startoptions[:frequency] = frequency
        end

		# Set sitemap link priority option
        options.on( '-p', '--priority <value>', 'Specify sitemap generated links priority. (required)
        			     Possible value range: 0.0 to 1.0' ) do |priority|
           startoptions[:priority] = priority
        end

		# Set Path for Sitemap output option
		options.on('-o', '--output <path>', 'Specify path where the newly generated sitemap should be placed. Do not include sitemap file name.') do |output|
			startoptions[:output] = output
		end
	end

	# Process and validate input startup options
	begin
		optparse.parse!

		required = [:domain, :host, :dbname, :user, :password, :output, :frequency, :priority]
		missing = required.select{ |param| startoptions[param].nil? }

		if not missing.empty?
			puts "\nWhaaa....Why you not provide this options? #{missing.join(', ')}"
			puts optparse
			exit
		end

		inputdomain = startoptions[:domain].to_s
		if inputdomain =~ /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix
		else
			puts "\nWhy are being mean with input domain name (blog URL)?"
			puts optparse
			exit
		end

		inputpriority = startoptions[:priority].to_f
		if inputpriority < 0.0 || inputpriority > 1.0
			puts "\nYou made a boo boo for input priority option?"
			puts optparse
			exit
		end

		inputfrequency = startoptions[:frequency].to_s
		if inputfrequency != 'always' && inputfrequency != 'hourly' && inputfrequency != 'daily' && inputfrequency != 'weekly' && inputfrequency != 'monthly' && inputfrequency != 'yearly' && inputfrequency != 'never'
			puts "\nStop messing with input frequency option?"
			puts optparse
			exit
		end

	rescue OptionParser::InvalidOption, OptionParser::MissingArgument
		puts $!.to_s
		puts optparse
		exit
	end

	puts "\nStart execution: " + Time.now.utc.to_s
	puts "\nYour options:" unless !startoptions[:verbose]
	pp startoptions unless !startoptions[:verbose]

	# Create MySQL connection.
	puts "\nConnecting database..." unless !startoptions[:verbose]
	dbconnection = Mysql.new startoptions[:host], startoptions[:user], startoptions[:password], startoptions[:dbname]
	puts "Connected to MySQL Ghost database successfully" unless !startoptions[:verbose]

	# Get post per page setting value.
	puts "\nFetching post per page setting value..." unless !startoptions[:verbose]
	getpostperpageresult = dbconnection.query "SELECT value AS PostPerPage FROM settings AS GS WHERE GS.key = 'postsPerPage';"
	postperpage = 0
	getpostperpageresult.each_hash do |count|
		postperpage = count['PostPerPage'].to_i
	end
	puts "Post per page => #{postperpage}" unless !startoptions[:verbose]

	# Get posts data.
	puts "\nFetching all post (which are in published state) information..." unless !startoptions[:verbose]

	getpostonlycount = dbconnection.query "SELECT COUNT(page) AS PostCount FROM posts WHERE page = 0;"
	postonlycount = 0
	getpostonlycount.each_hash do |postoc|
		postonlycount = postoc['PostCount'].to_i
	end

	getpageonlycount = dbconnection.query "SELECT COUNT(page) AS PageCount FROM posts WHERE page = 1;"
	pageonlycount = 0
	getpageonlycount.each_hash do |pageoc|
		pageonlycount = pageoc['PageCount'].to_i
	end

	getpostsresult = dbconnection.query "SELECT slug, updated_at FROM posts WHERE status = 'published';"
	totalposts = getpostsresult.num_rows

	paginationcount = (totalposts.to_f / postperpage.to_f).round

	puts "Total number of post (item) found => #{totalposts}, #{postonlycount} article and #{pageonlycount} static page" unless !startoptions[:verbose]

	# Get tags data.
	puts "\nFetching all tag (which are referenced by post) information..."  unless !startoptions[:verbose]
	gettagsresult = dbconnection.query "SELECT TG.slug AS tagslug, COUNT(*) AS Count FROM posts_tags PG INNER JOIN tags TG ON TG.id = PG.tag_id GROUP BY PG.tag_id ORDER BY Count DESC;"
	totaltags = gettagsresult.num_rows
	puts "Total number of referred tags found => #{totaltags}" unless !startoptions[:verbose]

	puts "\nGenerating some serious sitemap..." unless !startoptions[:verbose]
	SitemapGenerator::Sitemap.default_host = startoptions[:domain]
	# Display Sitemap generator verbose based on our verbose value.
	if startoptions[:verbose] == true
		SitemapGenerator::Sitemap.verbose = true
	else
		SitemapGenerator::Sitemap.verbose = false
	end
	SitemapGenerator::Sitemap.ping_search_engines unless !startoptions[:ping]
	SitemapGenerator::Sitemap.public_path = startoptions[:output] unless !startoptions[:output]
	SitemapGenerator::Sitemap.create do

		# Add URL for all post list pages (home page - pagination).
		for pagecounter in 1 ... paginationcount + 1
			add '/page/' + pagecounter.to_s + '/', :changefreq => startoptions[:frequency], :priority => startoptions[:priority], :lastmod => Time.now.strftime("%Y-%m-%dT%H:%M:%S+00:00")
        end

		# Add URL for RSS.
		add '/rss/', :changefreq => startoptions[:frequency], :priority => startoptions[:priority], :lastmod => Time.now.strftime("%Y-%m-%dT%H:%M:%S+00:00")

		# Add URL for all posts.
		getpostsresult.each_hash do |post|
			#puts post['slug']
			add '/' + post['slug'] + '/', :changefreq => startoptions[:frequency], :priority => startoptions[:priority], :lastmod => Time.parse(post['updated_at']).strftime("%Y-%m-%dT%H:%M:%S+00:00")
		end

		# Add URL for all tags with pagination.
        gettagsresult.each_hash do |tag|
        	tagrefcount = tag['Count'].to_i
        	tagsslug = tag['tagslug'].to_s
        	tagpaginationcount = 0
        	if tagrefcount == 1 || tagrefcount == 2
        		tagpaginationcount = 1
        	else
        		tagpaginationcount = (tagrefcount.to_f / postperpage.to_f).round
        	end

        	if tagpaginationcount == 0
        		add '/tag/' + tagsslug + '/', :changefreq => startoptions[:frequency], :priority => startoptions[:priority], :lastmod => Time.now.strftime("%Y-%m-%dT%H:%M:%S+00:00")
        	else
        		for tagpaginationcounter in 1 ... tagpaginationcount + 1
        			if tagpaginationcounter == 1
        				add '/tag/' + tagsslug + '/', :changefreq => startoptions[:frequency], :priority => startoptions[:priority], :lastmod => Time.now.strftime("%Y-%m-%dT%H:%M:%S+00:00")
        			else
        				add '/tag/' + tagsslug + '/page/' + tagpaginationcounter.to_s + '/', :changefreq => startoptions[:frequency], :priority => startoptions[:priority], :lastmod => Time.now.strftime("%Y-%m-%dT%H:%M:%S+00:00")
        			end
        		end
        	end
        end
	end

	puts "Taddam..Sitemap generated successfully !!" unless !startoptions[:verbose]
	puts "\nEnd execution " + Time.now.utc.to_s

# => Print issues with MySQL if any on console
rescue Mysql::Error => problem
		puts problem.errno
		puts problem.error
ensure
	dbconnection.close if dbconnection
end