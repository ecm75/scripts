#!/usr/local/rvm/rubies/ruby-2.2.4/bin/ruby

require 'net/http'
require 'json'
require './_parser.inc.rb'

# configuration
@idb_url = "https://idb.example.com"
@idb_apikey = 'xxxxxxxxxxxxxxxxxxxx'
@oxi_url = "https://oxidized.example.com"

$debug = false
if ARGV.include? '-d'
	$debug = true
end

# get all oxidized nodes
def oxidized_get_node_list()
	puts "oxidized_get_node_list()" if $debug == true
	url = "#{@oxi_url}/nodes?format=json"
	uri = URI(url)
    response = Net::HTTP.get(uri)
	data = JSON.parse(response)
	if data.length > 0
		puts data if $debug
		return data
	else
		return nil
	end
end

# fetch node info from oxidized
def oxidized_get_node_info(name)
	puts "oxidized_get_node_info(name)" if $debug
	url = "#{@oxi_url}/node/show/#{name}?format=json"
	uri = URI(url)
	response = Net::HTTP.get(uri)
	data = JSON.parse(response)
	if data.length > 0 && data['name'] != ''
		puts data if $debug
		return data
	else
        return nil
	end
end

#fetch node configuration from oxidized
def oxidized_get_node_config(node)
	puts "oxidized_get_node_config(node)" if $debug
	if node['name'] !~ /(?=^.{4,253}$)(^((?!-)[a-zA-Z0-9-]{1,63}(?<!-)\.)+[a-zA-Z]{2,63}$)/ && node['name'] !~ /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
		puts " #{node['name']} is not a valid FQDN!"
		return false
	end
	url = "#{@oxi_url}/node/fetch/asa-firewall/#{node['name']}"
	uri = URI(url)
	data = Net::HTTP.get(uri)
	if data && data != ''
#		puts data if $debug
		return data
	else
		return nil
	end
end

# put node info into IDB
def idb_put_node_info(node, data)
	puts "idb_put_node_info(node, data)" if $debug
	uri = URI.parse("#{@idb_url}/api/v3/machines/#{node['name']}")
	http = Net::HTTP.new(uri.host, uri.port)
	http.use_ssl = true
	request = Net::HTTP::Put.new(uri)
	request.set_form_data(data)
	request['X-IDB-API-Token'] = @idb_apikey
	res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
		http.request(request)
	end
	if res.body && res.body != ''
		return true
	else
		return false
	end
end

parser = Parser.new

nodes = oxidized_get_node_list()
nodes.each do |node|
	config = "";
	puts "checking: #{node['name']} ..."
	if config = oxidized_get_node_config(node)
		puts "  got config. parsing config..."
		data = parser.parse(node,config)
		if data.length > 0
			puts "   parsed config. updating IDB..."
			idb_put_node_info(node, data)
		else
			puts "  unable to parse config, nothing to update."
		end
	end
	puts
end
