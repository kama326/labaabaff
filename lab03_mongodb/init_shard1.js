// init_shard1.js
try {
    rs.initiate({
        _id: 'shard1rs',
        members: [{ _id: 0, host: 'shard1:27017' }]
    });
} catch (e) { print(e); }
