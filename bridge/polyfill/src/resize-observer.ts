type BoxSize = {blockSize: number, inlineSize: number};
export class ResizeObserver {
  private resizeChangeListener:(entries:Array<ResizeObserverEntry>)=>void;
  private targets:Array<HTMLElement> = [];
  private cacheEvents:Array<CustomEvent> = [];
  private dispatchEvent:Function;
  private pending:bool = false;
  constructor(callBack: (entries: Array<ResizeObserverEntry>)=>void) {
    this.resizeChangeListener = callBack;
    this.handleResizeEvent = this.handleResizeEvent.bind(this);
  }

  observe(target: HTMLElement) {
    if(this.targets.filter((item)=> item === target).length > 0) {
      return;
    }
    this.targets.push(target);
    target.addEventListener('resize', this.handleResizeEvent);
  }

  handleResizeEvent(event: any) {
    this.cacheEvents.push(event);
    this.pending = true;
    requestAnimationFrame(()=>{
        sendEventToElement();
        this.pending = false;
    });
  }

  sendEventToElement() {
    if(this.cacheEvents.length > 0) {
      const entries = this.cacheEvents.map((item)=>{
        const detail = JSON.parse(item.detail);
        return new ResizeObserverEntry(item.target!, detail.borderBoxSize, detail.contentBoxSize, detail.contentRect);
      });
      this.resizeChangeListener(entries);
      this.cacheEvents = [];
    }
  }

  unobserve(target: HTMLElement) {
    target.removeEventListener('resize', this.handleResizeEvent);
    this.targets = this.targets.filter((item)=> item !== target);

  }
}
class ResizeObserverEntry {
  public target: EventTarget;
  public borderBoxSize: BoxSize;
  public contentBoxSize: BoxSize;
  public contentRect: {width: number, height: number};
  constructor(target: EventTarget, borderBoxSize:BoxSize, contentBoxSize:BoxSize,
    contentRect:{width: number, height: number}) {
    this.target = target;
    this.borderBoxSize = borderBoxSize;
    this.contentBoxSize = contentBoxSize;
    this.contentRect = contentRect;
  }
}
