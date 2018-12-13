$model = "Ios"

module Ios
	def ios(config)
		version = ''
		serial = ''
		model = ''
		cpu = ''
		memory = 0
		disksize = 0

		if config.match(/(^! Cisco I.*)^version/m)
			desc = $1.strip.gsub(/^! /, '').gsub(/^!$/, '').gsub(/^\n$/, '')
		end

		if config.match(/Memory: main (\d+)/)
			memory = $1.strip.to_i / 1024
		end 

		if config.match(/CPU: (.*)$/)
			cpu = $1.strip
		end

		if config.match(/(PID:|Chassis type:)\s*([^, ]+)\s*[,\n]/)
			model = $2.strip
		end

		if config.match(/Memory: flash (\d+)(\w)$/)
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

		if config.match(/(SN:|Processor ID:)\s*(\w+),?$/)
			serial = $2.strip
		end

		if config.match(/(Software: [\w\-\,]+ | Version )([\w\(\)\.]+)/)
			version = $2.strip
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
