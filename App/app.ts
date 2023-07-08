import * as express from 'express';

const app = express();
const port = 3000

app.get('/', (req, res) => {
res.send('A Perfectly Working Master Branch with feature A!');
});

app.listen(port, function () {
console.log(`App is listening on port ${port}!`);
});