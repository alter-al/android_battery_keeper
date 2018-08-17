@max_battery_level = 42
@charging_file = '/sys/class/power_supply/battery/charging_enabled'.freeze

def devices
  `adb devices`.scan(/\n(.*)\t/).flatten
end

def unplug(udid:)
  charging = (`adb -s #{udid} shell "su -c 'cat #{@charging_file}'"`.to_i == 1)
  puts "🔋 Charging enabled: #{charging}"
  `adb -s #{udid} shell "su -c 'echo 0 > #{@charging_file}'"`
  puts "🔌 Unplug #{udid}" if charging
end

def plug(udid:)
  charging = (`adb -s #{udid} shell "su -c 'cat #{@charging_file}'"`.to_i == 1)
  puts "🔋 Charging enabled: #{charging}"
  `adb -s #{udid} shell "su -c 'echo 1 > #{@charging_file}'"`
  puts "🔌 Plug #{udid}" unless charging
end

def battery(udid:)
  battery_level = /level: (.*?)\n/.match(`adb -s #{udid} shell dumpsys battery`)
  raise("⚠️ Could not get battery level from: #{udid}") if battery_level[1].nil?
  puts "💡 Battery level: #{battery_level[1]}"
  battery_level[1].to_i
end

def battery_saver
  devices.each do |udid|
    next if udid.include?('emulator')
    puts "📱 #{udid}"
    battery_level = battery(udid: udid)
    battery_level > @max_battery_level ? unplug(udid: udid) : plug(udid: udid)
  end
end

battery_saver
