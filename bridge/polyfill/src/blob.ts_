import {webf} from './webf';
export class Blob{
    private id:string;
    constructor(){
        this.id = webf.invokeModule('Blob', 'init');
    }
    public append(name:string,value:any):void{
        webf.invokeModule('Blob','append',[this.id,name,value]);
    }
    public toString():string{
        return webf.invokeModule('Blob','toString',[this.id]);
    }
}