$model = "IosXR"

module IosXR
	def iosxr(config)
		version = ''
		serial = ''
		model = ''
		cpu = ''
		memory = 0
		disksize = 0

		if config.match(/(^! Cisco I.*)^hostname/m)
			desc = $1.strip.gsub(/^! /, '')
		end

		if config.match(/with (\d+)(\w) bytes of memory/)
			memory = $1.strip.to_i
			if $2 =~ /k/i
				memory = memory / 1024
			end
		end 

		if config.match(/(\w+) processor$/)
			cpu = $1.strip
		end

		if config.match(/(\w+[ -]\w+) .* Chassis/)
			model = $1.strip
		end

		if config.match(/(\d+)(\w+) bytes of hard disk/)
			hdd_size = $1.strip.to_i
			hdd_mult = $2.strip
			if hdd_mult =~ /KB?/i
				disksize = hdd_size * 1024
			elsif hdd_mult =~ /MB?/i
				disksize = hdd_size * 1024 * 1024
			elsif hdd_mult =~ /GB?/i
				disksize = hdd_size * 1024 * 1024 * 1024
			elsif hdd_mult =~ /TB?/i
				disksize = hdd_size * 1024 * 1024 * 1024 * 1024
			else
				disksize = hdd_size
			end
		end

		if config.match(/(A9K-RSP440-SG|A9K-RSP-4G).*?SN: (\w+)/)
			serial = $2.strip
		end

		if config.match(/, Version ([\w\.]+)/)
			version = $1.strip
		end

		puts "version: #{version}, model: #{model}, ram: #{memory}, serial: #{serial}, disksize: #{disksize}, cpu: #{cpu}" if $debug
		puts "desc: #{desc}" if $debug

		if (version != '' && serial != '' && model != '')
			data = {"os_release" => "#{version}", "arch" => "#{model}", "ram" => "#{memory}", "serialnumber" => "#{serial}", "diskspace" => "#{disksize}", "description" => "```\n#{desc}\n```"}
			puts " #{data}" if $debug
			return data
		else
			return {}
		end
	end
end
