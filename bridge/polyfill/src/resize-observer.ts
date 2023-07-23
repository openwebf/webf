type BoxSize = {blockSize: number, inlineSize: number};
export class ResizeObserver {
  private resizeChangeListener:(entries:Array<ResizeObserverEntry>)=>void;
  private targets:Array<HTMLElement> = [];
  private cacheEvents:Array<CustomEvent> = [];
  constructor(callBack:(entries:Array<ResizeObserverEntry>)=>void) {
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
  }

  unobserve(target: HTMLElement) {
    target.removeEventListener('resize',this.handleResizeEvent);
    this.targets = this.targets.filter((item)=> item !== target);
  }

  disconnect(target: HTMLElement) {
    this.targets.forEach((item)=>{
      item.removeEventListener('resize',this.handleResizeEvent);
    });
    this.targets = [];
    this.cacheEvents = [];
  }
}
class ResizeObserverEntry {
  public target: HTMLElement;
  public borderBoxSize: BoxSize;
  public contentBoxSize: BoxSize;
  public contentRect: {width: number, height: number};
  constructor(target: HTMLElement, borderBoxSize:BoxSize, contentBoxSize:BoxSize,
    contentRect:{width: number, height: number}) {
    this.target = target;
    this.borderBoxSize = borderBoxSize;
    this.contentBoxSize = contentBoxSize;
    this.contentRect = contentRect;
  }
}
