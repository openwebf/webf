
// @ts-ignore
export class DOMException extends Error {
  private message: string;
  private name: string;

  constructor(message = '', name = 'Error') {
    super();
    this.name = name;
    this.message = message;
  }
}