$model = "Asa"

module Asa
	def asa(config)
		version = ''
		serial = ''
		model = ''
		cpu = ''
		memory = 0
		disksize = 0
        desc = ''

		if config.match(/(^! Cisco A.*SN:[\s\w]+)\n/m)
			desc = $1.strip.gsub(/^! /, '')
		end

		if config.match(/Hardware:\s*(.*)$/)
			system = $1.split(', ')
			memory = system[1].gsub(/ [KMG]B? RAM/, "").strip
			cpu = system[2].gsub(/CPU /, '').strip
			model = system[0].strip
		end

		if config.match(/Internal ATA Compact Flash,\s*(\d+)\s*(\w*)$/)
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

		if config.match(/Serial Number:\s*(\w+)$/)
			serial = $1.strip
		end

		if config.match(/ASA Version (.*)$/)
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
