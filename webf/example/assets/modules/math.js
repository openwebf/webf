// math.js - ES Module example
export function add(a, b) {
    return a + b;
}

export function multiply(a, b) {
    return a * b;
}

export const PI = 3.14159;

export default function calculate(operation, a, b) {
    switch(operation) {
        case 'add': return add(a, b);
        case 'multiply': return multiply(a, b);
        default: throw new Error(`Unknown operation: ${operation}`);
    }
}