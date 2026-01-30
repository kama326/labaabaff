// init_router.js
try {
    sh.addShard('shard1rs/shard1:27017');
    sh.addShard('shard2rs/shard2:27017');
    sh.enableSharding('test');
    sh.shardCollection('test.cities', { name: 1 });
} catch (e) { print(e); }
