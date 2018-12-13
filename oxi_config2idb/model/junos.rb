$model = "JunOS"

module JunOS
	def junos(config)
		version = ''
		serial = ''
		model = ''
		cpu = ''
		memory = 0
		disksize = 0

		if config.match(/(^. fpc.*)/m)
			desc = $1.strip.gsub(/^# /, '')
		end

		if config.match(/^. Model: (.*)$/)
			model = $1.strip.upcase
		end

		if config.match(/^. Chassis\s+(\w+)\s+([\w\-\W]+)$/)
			serial = $1.strip
		end

		if config.match(/^. Junos: (.*)$/)
			version = $1.strip
		elsif config.match(/^. JUNOS Base OS boot \[(.*)\]/)
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
