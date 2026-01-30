include Java
import 'org.apache.hadoop.hbase.client.ConnectionFactory'
import 'org.apache.hadoop.hbase.client.Put'
import 'org.apache.hadoop.hbase.util.Bytes'
import 'javax.xml.stream.XMLInputFactory'
import 'javax.xml.stream.XMLStreamConstants'
import 'java.io.FileInputStream'
require 'time'

# Вспомогательный метод для байтов
def jbytes(str)
  Bytes.toBytes(str.to_s)
end

# Настройка соединения и таблицы
conf = @hbase.configuration
connection = ConnectionFactory.createConnection(conf)
# Убедимся что таблица есть (она создается в day1_script)
admin = connection.getAdmin()
unless admin.tableExists(org.apache.hadoop.hbase.TableName.valueOf('wiki'))
    create 'wiki', 'text', 'revision'
end

table = connection.getTable(org.apache.hadoop.hbase.TableName.valueOf('wiki'))
# table.setAutoFlush(false) # В новых версиях API это управляется иначе, но для шелла оставим по умолчанию

filename = '/scripts/wiki_dump.xml'
factory = XMLInputFactory.newInstance
reader = factory.createXMLStreamReader(FileInputStream.new(filename))

document = nil
buffer = nil
count = 0

puts "Starting Wiki import..."

while reader.hasNext
  type = reader.next
  
  if type == XMLStreamConstants::START_ELEMENT
    tag = reader.getLocalName
    if tag == 'page'
      document = {}
    elsif ['title', 'timestamp', 'username', 'comment', 'text'].include?(tag)
      buffer = ""
    end
    
  elsif type == XMLStreamConstants::CHARACTERS
    buffer << reader.getText if buffer
    
  elsif type == XMLStreamConstants::END_ELEMENT
    tag = reader.getLocalName
    
    if ['title', 'timestamp', 'username', 'comment', 'text'].include?(tag)
      document[tag] = buffer.strip if document
      buffer = nil
    elsif tag == 'revision'
      # Вставляем данные
      key = jbytes(document['title'])
      # Parsing timestamp requires more complex logic in JRuby sometimes, simplifying for demo:
      ts = Time.now.to_i * 1000 
      
      p = Put.new(key, ts)
      p.addColumn(jbytes("text"), jbytes(""), jbytes(document['text']))
      p.addColumn(jbytes("revision"), jbytes("author"), jbytes(document['username']))
      p.addColumn(jbytes("revision"), jbytes("comment"), jbytes(document['comment']))
      
      table.put(p)
      count += 1
      puts "Imported page: #{document['title']}"
    end
  end
end

puts "Wiki import finished. Total: #{count}"
table.close()
exit
