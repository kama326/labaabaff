const AWS = require('aws-sdk');

// Настройка клиента для локальной DynamoDB
const dynamodb = new AWS.DynamoDB({
    endpoint: 'http://dynamodb:8000',
    region: 'us-east-1',
    accessKeyId: 'fake',
    secretAccessKey: 'fake'
});

const TABLE_NAME = 'SensorData';
const SENSORS = ['sensor-1', 'sensor-2', 'sensor-3'];
const ITERATIONS = 50; // Количество записей на датчик

console.log("Starting Pipeline Simulation...");

async function runSimulation() {
    for (const sensorId of SENSORS) {
        console.log(`Generating data for ${sensorId}...`);

        let currentTemp = 70.0;
        let currentTime = Math.floor(Date.now() / 1000) - (ITERATIONS * 60); // Начинаем с прошлого

        for (let i = 0; i < ITERATIONS; i++) {
            // Random walk logic
            const change = (Math.random() - 0.5) * 2; // -1 to +1
            currentTemp += change;
            currentTime += 60; // +1 minute

            const params = {
                TableName: TABLE_NAME,
                Item: {
                    "SensorId": { S: sensorId },
                    "CurrentTime": { N: currentTime.toString() },
                    "Temperature": { N: currentTemp.toFixed(2) }
                }
            };

            try {
                await dynamodb.putItem(params).promise();
                // console.log(`Wrote: ${sensorId} @ ${currentTime} = ${currentTemp.toFixed(2)}`);
            } catch (err) {
                console.error("Error writing item:", err);
            }
        }
    }
    console.log("Simulation Completed. Data loaded.");
}

runSimulation();
