include Java
import 'org.apache.hadoop.hbase.client.ConnectionFactory'
import 'org.apache.hadoop.hbase.client.Put'
import 'org.apache.hadoop.hbase.util.Bytes'
import 'org.apache.hadoop.hbase.TableName'

# Настройка соединения
conf = @hbase.configuration
connection = ConnectionFactory.createConnection(conf)
admin = connection.getAdmin()

# Создание таблицы 'wiki' если не существует
table_name = TableName.valueOf('wiki')
unless admin.tableExists(table_name)
  puts "Creating 'wiki' table..."
  create 'wiki', 'text', 'revision' 
end

# Задание 1: Функция put_many
# Задание 1: Функция put_many
def put_many(connection, table_name, row, column_values)
  # Подключаемся к таблице
  table = connection.getTable(TableName.valueOf(table_name))
  
  # Создаем объект Put
  p = Put.new(Bytes.toBytes(row))
  
  # Проходим по хешу значений
  column_values.each do |key, value|
    parts = key.split(':')
    family = parts[0]
    qualifier = parts[1] || "" # Если квалификатор пустой 
    
    p.addColumn(Bytes.toBytes(family), Bytes.toBytes(qualifier), Bytes.toBytes(value))
  end
  
  # Отправляем данные
  table.put(p)
  puts "Row '#{row}' inserted successfully."
  table.close()
end

# Задание 2: Использование put_many
puts "Executing put_many..."
put_many connection, 'wiki', 'Some title', {
  "text" => "Some article text",
  "revision:author" => "jschmoe",
  "revision:comment" => "no comment" 
}

# Проверка результата
puts "Verifying insertion..."
count 'wiki'
scan 'wiki'

exit
