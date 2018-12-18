$model = "FortiOS"

module FortiOS
	def fortios(config)
		version = ''
		serial = ''
		model = ''
		cpu = ''
		memory = 0
		disksize = 0
        desc = ''

		if config.match(/^(# Version.*?)^# COMMAND: end/m)
			desc = $1.strip.gsub(/^#\s+/, '')
			desc.gsub!(/^(# )?COMMAND:.*$/, '')
			desc.gsub!(/\r/, '')
			desc.gsub!(/^\n+$/, '').gsub!(/\n\n+/, "\n").gsub!(/^\#$/, '')
		end

		if config.match(/^# RAM:\s*(.*)$/)
			memory = $1.gsub(/ [KMG]B? RAM/, "").strip
		end

		if config.match(/^# CPU:\s*(.*)$/)
			cpu = $1.gsub(/CPU /, '').strip
		end

		if config.match(/^# Model name:\s*(.*)$/)
			model = $1.strip
		end

		if config.match(/# Hard disk:\s*(\d+)\s*(\w*).*$/)
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

		if config.match(/^# Serial-Number:\s*(.*)$/)
			serial = $1.strip
		end

		if config.match(/^# Version:\s*(.*)$/)
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
