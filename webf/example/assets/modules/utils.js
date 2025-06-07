// utils.js - ES Module example
export function formatDate(date) {
    return date.toISOString().split('T')[0];
}

export function capitalize(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
}

export class Logger {
    constructor(prefix) {
        this.prefix = prefix;
    }
    
    log(message) {
        console.log(`[${this.prefix}] ${message}`);
    }
}