// init_configserver.js
try {
    rs.initiate({
        _id: 'configSet',
        configsvr: true,
        members: [{ _id: 0, host: 'mongoconfig:27017' }]
    });
} catch (e) { print(e); }
