$model = "Procurve"

module Procurve
	def procurve(config)
		version = ''
		serial = ''
		model = ''
		cpu = ''
		memory = 0
		disksize = 0
        desc = ''

		if config.match(/^!(.*?)^; \w+ Configuration Editor/m)
			desc = $1.strip.gsub(/\x1b\[[0-9;]*m?/, '')
			desc = desc.gsub(/\r/, '').gsub(/^! /, '')
		end

		if config.match(/Memory\s+-\s+Total\s*:\s([\d\,]+)/)
			memory = $1.gsub(/,/, '').strip
		end

		if config.match(/Serial Number\s+:\s(\w+)/)
			serial = $1.strip
		end

		if config.match(/(Software|Firmware) revision\s+:\s([^\s]+)/)
			version = $2.strip
		end 

        puts "version: #{version}, model: #{model}, ram: #{memory}, serial: #{serial}, disksize: #{disksize}, cpu: #{cpu}" if $debug
        puts "desc: #{desc}" if $debug

		if (version != '' && serial != '')
			data = {"os_release" => "#{version}", "ram" => "#{memory}", "serialnumber" => "#{serial}", "diskspace" => "#{disksize}", "description" => "```\n#{desc}\n```"}
			puts " #{data}" if $debug
			return data
		else
			return {}
		end
	end
end
