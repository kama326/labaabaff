$Headers = @{
    Authorization = "Basic bmVvNGo6cGFzc3dvcmQ="
    "Content-Type" = "application/json"
}
$Url = "http://localhost:7474/db/neo4j/tx/commit"

Write-Host "--- Checking Neo4j Status ---"
$Body = '{ "statements": [] }'
try {
    $Response = Invoke-RestMethod -Uri $Url -Method Post -Headers $Headers -Body $Body
    Write-Host "Status OK. Elements: $($Response.results.Count)"
} catch {
    Write-Host "Error checking status: $_"
    exit 1
}

Write-Host "`n--- Creating Node via REST (P.G. Wodehouse) ---"
$Body = '{
  "statements": [
    {
      "statement": "CREATE (n:Author {name: $name, genre: $genre}) RETURN n",
      "parameters": {
        "name": "P.G. Wodehouse",
        "genre": "British Humour"
      }
    }
  ]
}'
$Response = Invoke-RestMethod -Uri $Url -Method Post -Headers $Headers -Body $Body
Write-Host "Node Created. Results: $($Response.results[0].data.Count)"

Write-Host "`n--- Creating another node and relationship via REST ---"
$Body = '{
  "statements": [
    {
      "statement": "CREATE (b:Book {title: \"Jeeves Takes Charge\"}) WITH b MATCH (a:Author {name: \"P.G. Wodehouse\"}) CREATE (a)-[:WROTE]->(b) RETURN a, b"
    }
  ]
}'
$Response = Invoke-RestMethod -Uri $Url -Method Post -Headers $Headers -Body $Body
Write-Host "Relationship Created. Results: $($Response.results[0].data.Count)"

Write-Host "`n--- Fulltext Search (Simulated via Cypher) ---"
# Index creation
$Body = '{
  "statements": [
    {
      "statement": "CREATE FULLTEXT INDEX bookTitles IF NOT EXISTS FOR (n:Book) ON EACH [n.title]"
    }
  ]
}'
Invoke-RestMethod -Uri $Url -Method Post -Headers $Headers -Body $Body
Write-Host "Index created."

Write-Host "`nRunning search for 'Jeeves':"
$Body = '{
  "statements": [
    {
      "statement": "CALL db.index.fulltext.queryNodes(\"bookTitles\", \"Jeeves\") YIELD node, score RETURN node.title, score"
    }
  ]
}'
try {
    $Response = Invoke-RestMethod -Uri $Url -Method Post -Headers $Headers -Body $Body
    Write-Host "Search Results:"
    $Response.results[0].data | ForEach-Object {
        Write-Host "Title: $($_.row[0]) - Score: $($_.row[1])"
    }
} catch {
    Write-Host "Error during search: $_"
}
