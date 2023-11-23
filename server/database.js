import pg from 'pg'
import { DB_URL } from './config.js';
import positionStream from './position-stream.js';

const client = new pg.Client({
    connectionString: DB_URL
})
await client.connect();

let currentRoutes = new Map();
const subscriptions = [];

export function subscribe (cb) {
    subscriptions.push(cb);
}

function publish (pos) {
    for (let subscriber of subscriptions) {
        subscriber(pos);
    }
}

positionStream.on('data', async (pos) => {
    try {
        await recordPosition(pos.boat, pos.latitude, pos.longitude, pos.heading);
        publish(pos);
    } catch (err) {
        console.error('Error while writing position data to database', err);
    }
});

export function getCurrentRoute(boatId) {
    return currentRoutes.has(boatId) ? currentRoutes.get(boatId) : 0;
}

export async function startRoute (boatId) {
    const sql = 'INSERT INTO routes (boat_id) VALUES ($1) RETURNING id';
    const res = await client.query(sql, [boatId]);
    const routeId = res.rows[0].id;
    currentRoutes.set(boatId, routeId);
}

export function endRoute (boatId) {
    currentRoutes.delete(boatId);
}

export async function recordPosition (boatId, latitude, longitude, heading) {
    const sql = 'CALL insert_position($1, $2, $3, $4, $5)';
    await client.query(sql, [boatId, latitude, longitude, heading, getCurrentRoute(boatId)]);
}

export async function listRoutes (boatId) {
    const sql = 'SELECT * FROM route_list WHERE id !=$1 AND boat_id = $2';
    const res = await client.query(sql, [getCurrentRoute(boatId), boatId]);
    return res.rows;
}

export async function getRoute (routeId) {
    const sql = 'SELECT * FROM route_info WHERE route_id = $1';
    const res = await client.query(sql, [routeId]);
    return res.rows;
}

process.on('exit', () =>  client.end());