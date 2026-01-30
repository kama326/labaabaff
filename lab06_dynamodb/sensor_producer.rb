require 'json'
require 'time'

# Этот скрипт имитирует producer для Kinesis (как в задании), но для локальной версии мы используем Node.js симуляцию напрямую в DynamoDB.
# Здесь приведен код для ознакомления/отчета.

STREAM_NAME = 'temperature-sensor-data'
SENSOR_ID = ARGV[0] || 'sensor-1'
ITERATIONS = (ARGV[1] || 10).to_i

puts "Starting sensor simulation for #{SENSOR_ID}..."

ITERATIONS.times do |i|
  temp = 70.0 + rand(-5.0..5.0)
  data = {
    sensor_id: SENSOR_ID,
    current_time: Time.now.to_i,
    temperature: temp.round(2)
  }
  
  # В реальном сценарии: 
  # kinesis.put_record(stream_name: STREAM_NAME, data: data.to_json, partition_key: 'sensor-data')
  puts "Generated data: #{data.to_json}"
  sleep 0.1
end
