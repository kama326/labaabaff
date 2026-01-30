#!/bin/bash
COUCH_URL="http://admin:password@localhost:5984"
DB_NAME="music"

echo "Populating '$DB_NAME' with random artists..."

for i in {1..50}
do
   name="Artist_$RANDOM"
   album="Album_$RANDOM"
   track="Track_$RANDOM"
   random_val="0.$RANDOM"
   
   curl -s -X POST "$COUCH_URL/$DB_NAME" \
     -H "Content-Type: application/json" \
     -d "{
       \"name\": \"$name\",
       \"random\": $random_val,
       \"albums\": [
         {\"title\": \"$album\", \"year\": 2000, \"tracks\": [
            {\"title\": \"$track\", \"tags\": [{\"idstr\": \"rock\"}, {\"idstr\": \"pop\"}]}
         ]}
       ]
     }" > /dev/null
done
echo "Done."
