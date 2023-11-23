import { DataStream } from "./data-stream.js";
import { WebSocketServer } from 'ws';
import { PORT } from "./config.js";

// start streaming position data
const dataStream = new DataStream();

dataStream.on('error', err => {
    console.error(err)
})

dataStream.on('end', () => {
    process.exit();
})


// create WS server
const wss = new WebSocketServer({ port: PORT });

wss.on('connection', ws => {
    ws.on('error', console.error);

    const dataListener = pos => {
        ws.send(JSON.stringify(pos));
    }

    dataStream.on('data', dataListener); 

    ws.on('close', () => dataStream.off('data', dataListener));
});