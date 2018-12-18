$model = "SROS"

module SROS
	def sros(config)
		version = ''
		serial = ''
		model = ''
		cpu = ''
		memory = 0
		disksize = 0
        desc = ''

		if config.match(/(^# =+.*?)^exit all$/m)
			desc = $1.strip.gsub(/^# /, '')
		end

		if config.match(/^# System Type\s*: (.*)$/)
			model = $1.strip.upcase
		end

		if config.match(/^# Board Serial Number is .(.*).$/)
			serial = $1.strip
		end

		if config.match(/^# System Version\s*: (.*)$/)
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
