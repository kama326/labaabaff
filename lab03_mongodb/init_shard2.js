// init_shard2.js
try {
    rs.initiate({
        _id: 'shard2rs',
        members: [{ _id: 0, host: 'shard2:27017' }]
    });
} catch (e) { print(e); }
