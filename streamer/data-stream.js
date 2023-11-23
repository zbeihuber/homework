import { EventEmitter } from 'node:events'
import { CSVReader } from './csv-reader.js'
import { DATA_FILE  } from './config.js'

const BOAT = 1;

export class DataStream extends EventEmitter {
    constructor () {
        super();
        this.reader = new CSVReader(DATA_FILE);
        setInterval(async () => {
            try {
                let data = await this.reader.getNextRecord();
                if (data === null) {
                    this.emit('end')
                } else {
                    this.emit('data', {
                        boat: BOAT,
                        latitude: data[0],
                        longitude: data[1],
                        heading: data[2]
                    })
                }
            } catch (e) {
                this.emit('error', e);
            }
        }, 1000);
    }
}