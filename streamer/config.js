import  { fileURLToPath } from 'node:url';

export const DATA_FILE =  fileURLToPath(new URL('./data/line1.csv', import.meta.url));
export const PORT = 4300;