import { EventEmitter } from "node:events";
import { STREAMER_ADDRESS } from "./config.js";
import WebSocket from 'ws';

class PositionStream extends EventEmitter {
    constructor() {
        super();
        this.connect()
    }

    connect () {
        let ws = new WebSocket(STREAMER_ADDRESS);
        ws.on('error', err => {
            console.error("Error while reading position stream:", err.code);
        });
        ws.on('close', () => {
            this.reconnect();
        })
        ws.on('message', msg => {
            let pos = JSON.parse(msg);
            this.emit('data', pos);
        });
    }

    reconnect () {
        setTimeout(() => {this.connect()}, 3000);
    }
}

const positionStream = new PositionStream(); 

export default positionStream;