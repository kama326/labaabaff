const http = require('http');

// Задание 12: Реализуйте watcher.start для отслеживания изменений (longpoll)

const options = {
    hostname: 'localhost',
    port: 5984,
    path: '/music/_changes?feed=longpoll&include_docs=true&since=0',
    method: 'GET',
    headers: {
        'Authorization': 'Basic ' + Buffer.from('admin:password').toString('base64')
    }
};

console.log("Starting Change Watcher...");

function watchChanges(since) {
    if (since) {
        options.path = `/music/_changes?feed=longpoll&include_docs=true&since=${since}`;
    }

    const req = http.request(options, (res) => {
        let data = '';

        res.on('data', (chunk) => {
            data += chunk;
        });

        res.on('end', () => {
            try {
                const response = JSON.parse(data);
                if (response.results) {
                    response.results.forEach(change => {
                        console.log(`Change detected: ${change.id} (Seq: ${change.seq})`);
                        if (change.doc) {
                            console.log(` -> Document Name: ${change.doc.name}`);
                        }
                    });
                    // Перезапускаем с последнего sequence
                    watchChanges(response.last_seq);
                }
            } catch (e) {
                console.error("Error parsing response:", e);
                // Retry after delay
                setTimeout(() => watchChanges(since), 5000);
            }
        });
    });

    req.on('error', (e) => {
        console.error(`Problem with request: ${e.message}`);
        setTimeout(() => watchChanges(since), 5000);
    });

    req.end();
}

watchChanges(0);
