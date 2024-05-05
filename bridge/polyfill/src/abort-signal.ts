const SECRET = {};

// @ts-ignore
export class _AbortSignal extends EventTarget {
  public _aborted: boolean;

  get aborted() {
    return this._aborted;
  }

  constructor(secret: any) {
    super();
    if (secret !== SECRET) {
      throw new TypeError("Illegal constructor.");
    }
    this._aborted = false;
  }

  private _onabort: any;
  get onabort() {
    return this._aborted;
  }
  set onabort(callback: any) {
    const existing = this._onabort;
    if (existing) {
      this.removeEventListener("abort", existing);
    }
    this._onabort = callback;
    this.addEventListener("abort", callback);
  }

}

export class _AbortController {
  public _signal: _AbortSignal;
  constructor() {
    this._signal = new _AbortSignal(SECRET);
  }

  get signal() {
    return this._signal;
  }

  abort() {
    const signal = this.signal;
    if (!signal.aborted) {
      signal._aborted = true;
      signal.dispatchEvent(new Event("abort"));
    }
  }
}


