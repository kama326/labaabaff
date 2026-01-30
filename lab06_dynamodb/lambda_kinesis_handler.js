var AWS = require('aws-sdk');
var DynamoDB = new AWS.DynamoDB({
    apiVersion: '2012-08-10',
    region: 'us-east-1',
});

// Этот код предназначен для AWS Lambda и не запускается локально в данной лабораторной.
// Он сохранен для справки и отчета.

exports.kinesisHandler = function (event, context, callback) {
    var kinesisRecord = event.Records[0];
    var data = Buffer.from(kinesisRecord.kinesis.data, 'base64').toString('ascii');
    var obj = JSON.parse(data);

    var sensorId = obj.sensor_id;
    var currentTime = obj.current_time;
    var temperature = obj.temperature;

    var item = {
        TableName: "SensorData",
        Item: {
            SensorId: { S: sensorId },
            CurrentTime: { N: currentTime.toString() },
            Temperature: { N: temperature.toString() }
        }
    };

    DynamoDB.putItem(item, function (err, data) {
        if (err) {
            console.log(err, err.stack);
            callback(err.stack);
        } else {
            console.log(data);
            callback(null, data);
        }
    });
}
