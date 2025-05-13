export interface NavigatorInterface {
    readonly userAgent: string;
    readonly platform: string;
    readonly language: string;
    readonly languages: string[];
    readonly appName: string;
    readonly appVersion: string;
    readonly hardwareConcurrency: number;
    readonly clipboard: {
        readText(): Promise<string>;
        writeText(text: string): Promise<void>;
    };
}
export declare const navigator: NavigatorInterface;
