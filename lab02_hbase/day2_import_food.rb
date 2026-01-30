include Java
import 'org.apache.hadoop.hbase.client.ConnectionFactory'
import 'org.apache.hadoop.hbase.client.Put'
import 'org.apache.hadoop.hbase.util.Bytes'
import 'org.apache.hadoop.hbase.TableName'
import 'javax.xml.stream.XMLInputFactory'
import 'javax.xml.stream.XMLStreamConstants'
import 'java.io.FileInputStream'

# Настройка соединения
conf = @hbase.configuration
connection = ConnectionFactory.createConnection(conf)
admin = connection.getAdmin()

# Создание таблицы 'foods'
table_name = TableName.valueOf('foods')
unless admin.tableExists(table_name)
  puts "Creating 'foods' table..."
  create 'foods', 'facts' 
end

def jbytes(str)
  Bytes.toBytes(str.to_s)
end

# Парсинг XML
filename = '/scripts/food_display_table.xml'
factory = XMLInputFactory.newInstance
reader = factory.createXMLStreamReader(FileInputStream.new(filename))

current_food = {}
buffer = nil
table = connection.getTable(table_name)
count = 0

puts "Starting import from #{filename}..."

while reader.hasNext
  type = reader.next
  
  if type == XMLStreamConstants::START_ELEMENT
    tag = reader.getLocalName
    if tag == 'Food_Display_Row'
      current_food = {}
    end
    buffer = "" # Reset buffer for new element
    
  elsif type == XMLStreamConstants::CHARACTERS
    buffer << reader.getText
    
  elsif type == XMLStreamConstants::END_ELEMENT
    tag = reader.getLocalName
    
    if tag == 'Food_Display_Row'
      # Конец строки - сохраняем в HBase
      row_key = current_food['Food_Code']
      if row_key
        p = Put.new(jbytes(row_key))
        current_food.each do |k, v|
          next if k == 'Food_Code'
          p.addColumn(jbytes('facts'), jbytes(k), jbytes(v))
        end
        table.put(p)
        count += 1
        puts "Imported food: #{current_food['Display_Name']}"
      end
    elsif tag != 'Food_Display_Table'
      # Сохраняем значение поля
      current_food[tag] = buffer.strip
    end
  end
end

puts "Import finished. Total rows: #{count}"
table.close()

# Проверка: запрос любимой еды (например Banana)
puts "Querying for Banana (Code 67890)..."
get 'foods', '67890'

exit
