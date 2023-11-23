import { open } from 'node:fs/promises';

export class CSVReader {
    constructor(filename) {
        this.filename = filename;
        this.lines = this.readLines()
        this.cursor = 0;
    }

    async readLines () {
        let file = await open(this.filename);

        let result = [];
        for await (let line of file.readLines()) {
            result.push(line);
        }

        file.close();

        return result;
    }  

    async getNextRecord () {
        let lines = await this.lines;
        
        this.cursor++;
        if (this.cursor >= lines.length) {
            return null
        }
        return lines[this.cursor].split(',').map(item => item.trim());
    }
}