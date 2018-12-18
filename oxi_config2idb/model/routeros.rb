$model = "RouterOS"

module RouterOS
	def routeros(config)
		version = ''
		serial = ''
		model = ''
		cpu = ''
		memory = 0
		disksize = 0
		desc = ''

		if config.match(/^(.\s*routerboard.*?)^[^#]/m)
			desc = $1.strip.gsub(/\r/, '').gsub(/^#\s*U\s.*\r?\n/, '').gsub(/^# /, '').gsub(/^#?$/, '')
		end

		if config.match(/^.\s*model: (.*)$/)
			model = $1.strip.upcase
		end

		if config.match(/^.\s*serial-number: (.*)$/)
			serial = $1.strip
		end

		if config.match(/^.\s*installed-version: (.*)$/)
			version = $1.strip
		end 

        puts "version: #{version}, model: #{model}, ram: #{memory}, serial: #{serial}, disksize: #{disksize}, cpu: #{cpu}" if $debug
        puts "desc:\n#{desc}" if $debug

		if (version != '' && serial != '' && model != '')
			data = {"os_release" => "#{version}", "arch" => "#{model}", "ram" => "#{memory}", "serialnumber" => "#{serial}", "diskspace" => "#{disksize}", "description" => "```\n#{desc}\n```"}
			puts " #{data}" if $debug
			return data
		else
			return {}
		end
	end
end
