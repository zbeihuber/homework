import express, { response } from 'express';
import { createServer } from 'node:http';
import { Server } from 'socket.io';
import cors from "cors"
import { PORT  } from './config.js';
import * as db from './database.js';

const app = express();
const server = createServer(app);


// middlewares
app.use(cors());


// REST API endpoints
app.get('/boats/:boatId/routes', (req, res, next) => {
    const boatId = req.params.boatId;
    db.listRoutes(boatId)
      .then(routes => res.json(routes))
      .catch(next);
});

app.get('/routes/:routeId', (req, res, next) => {
    const routeId = req.params.routeId;
    db.getRoute(routeId)
      .then(route => res.json(route))
      .catch(next);
});


// WS API
const io = new Server(server, {
    cors: {origin: true}
});

const recordings = new Map();
const positions = new Map();

function roomFor(boatId) {
    return `boat_${boatId}`;
}

function braoadcast (boatId, subject, ...data) {
    io.to(roomFor(boatId)).emit(subject, ...data);
}

db.subscribe(pos => {
    const boatId = pos.boat;
    positions.set(boatId, pos);
    braoadcast (boatId, 'position', pos);
    
    if (recordings.has(boatId)) {
        recordings.get(boatId).push(pos);
    }
})

io.on('connection', (socket) => {
    socket.on('watch', ({boat}) => {
        socket.join(roomFor(boat));
        const state = {
            position: positions.get(boat), 
            isRecording: recordings.has(boat) == true
        }
        state.route = state.isRecording ? recordings.get(boat) : [];
        socket.emit('state', state);
    });

    socket.on('unwatch', ({boat}) => {
        socket.leave(roomFor(boat));
    });

    socket.on('start recording', async ({boat}) => {
        if (recordings.has(boat) == false) {
            recordings.set(boat, []);
            await db.startRoute(boat);
            braoadcast(boat, 'recording started');
        }
    });

    socket.on('stop recording', ({boat}) => {
        if (recordings.has(boat) == true) {
            recordings.delete(boat);
            db.endRoute();
            braoadcast(boat, 'recording stopped');
        }
    });
});


// start server
server.listen(PORT, () => {
  console.log(`server running at http://localhost:${PORT}`);
});