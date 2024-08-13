import {webf} from './webf';

export class ArrayBuffer{
    private id:string;
    private byteLength?:number=0;
    constructor(byteLength?:number){
        this.byteLength=byteLength;
        this.id = webf.invokeModule('ArrayBufferData', 'init',[byteLength]);
    }
    public slice(start:number,end:number):void{
        webf.invokeModule('ArrayBufferData','slice',[this.id,start,end]);
    }
    public toString():string{
        return webf.invokeModule('ArrayBufferData','toString',[this.id]);
    }
}