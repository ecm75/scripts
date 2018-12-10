#!/usr/bin/ruby

require 'net/http'
require "uri"
require 'json'

# configuration
@idb_url = "https://idb.example.com"
@idb_apikey = 'xxxxxxxxxxxxxxxxxxxxxxxxx'
@oxi_url = "https://oxidized.example.com"

# get all oxidized nodes
def oxidized_get_node_list()
	url = "#{@oxi_url}/nodes?format=json"
	uri = URI(url)
    response = Net::HTTP.get(uri)
	data = JSON.parse(response)
	if data.length > 0
		return data
    else
        return nil
	end
end

# fetch node info from oxidized
def oxidized_get_node_info(name)
	url = "#{@oxi_url}/node/show/#{name}?format=json"
	uri = URI(url)
	response = Net::HTTP.get(uri)
	data = JSON.parse(response)
	if data && data['name'] != ''
		return data
	else
        return nil
	end
end

#fetch node configuration from oxidized
def oxidized_get_node_config(node)
    # check for valid fqdn
	if node['name'] !~ /(?=^.{4,253}$)(^((?!-)[a-zA-Z0-9-]{1,63}(?<!-)\.)+[a-zA-Z]{2,63}$)/
		puts " #{node['name']} is not a valid FQDN!"
		return false
	end
	url = "#{@oxi_url}/node/fetch/asa-firewall/#{node['name']}"
	uri = URI(url)
	node_config = Net::HTTP.get(uri)
	if node_config && node_config != ''
		return node_config
	else
        return nil
	end
end

# parse config
def parse_node_config(node, node_config)
	if node['model'] =~ /asa/i
		desc = node_config.match(/(^! Cisco.*SN.*?)\n/m)[1].gsub(/\n/, "  \n").gsub(/^!/, '')
		system = node_config.match(/Hardware:\s*(.*)$/)[1].split(', ')
		type = system[0].strip
		memory = system[1].gsub(/ [KMG]B RAM/, "").strip
		cpu = system[2].gsub(/CPU /, '').strip
		model = system[0].strip
		hdd = node_config.match(/Internal ATA Compact Flash,\s*(\d+)\s*(\w*)$/)
		hdd_size = hdd[1].strip.to_i
		hdd_mult = hdd[2].strip
		if hdd_mult =~ /KB/i
			disksize = hdd_size * 1024
		elsif hdd_mult =~ /MB/i
			disksize = hdd_size * 1024 * 1024
		elsif hdd_mult =~ /GB/i
			disksize = hdd_size * 1024 * 1024 * 1024
		elsif hdd_mult =~ /TB/i
			disksize = hdd_size * 1024 * 1024 * 1024 * 1024
		else
			disksize = hdd_size
		end
		serial = node_config.match(/Serial Number:\s*(\w+)$/)[1].strip
		version = node_config.match(/ASA Version (.*)$/)[1].strip
	end

	if (version != '' && serial != '')
		data = {"os_release" => "#{version}", "arch" => "#{model}", "ram" => "#{memory}", "serialnumber" => "#{serial}", "diskspace" => "#{disksize}", "description" => "#{desc}"}
		return data
	else
		return nil
	end
end

# put node info into IDB
def idb_put_node_info(node, data)
	puts "idb_put_node_info(node, data):" if DEBUG == true
	uri = URI.parse("#{@idb_url}/api/v3/machines/#{node['name']}")
	http = Net::HTTP.new(uri.host, uri.port)
	http.use_ssl = true
	request = Net::HTTP::Put.new(uri)
	request.set_form_data(data)
	request['X-IDB-API-Token'] = APIKey
	res = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
		http.request(request)
	end
	if res.body && res.body != ''
		return true
	else
		return false
	end
end

nodes = oxidized_get_node_list()
nodes.each { |node|
	puts "checking: #{node['name']} ..."
	if node['model'] =~ /asa/i
		puts " found ASA, getting config..."
		if config = oxidized_get_node_config(node)
			puts "  got config. parsing config..."
			data = parse_node_config(node, config)
			if data.length > 0
				puts "   parsed config. updating IDB..."
				idb_put_node_info(node, data)
			end
		end
	end
}
