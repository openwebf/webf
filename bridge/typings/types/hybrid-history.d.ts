export interface HybridHistoryInterface {
    readonly state: any;
    readonly path: string;
    back(): void;
    pushState(state: any, name: string): void;
    replaceState(state: any, name: string): void;
    restorablePopAndPushState(state: any, name: string): string;
    pop(result?: any): void;
    pushNamed(routeName: string, options?: {
        arguments?: any;
    }): void;
    pushReplacementNamed(routeName: string, options?: {
        arguments?: any;
    }): void;
    restorablePopAndPushNamed(routeName: string, options?: {
        arguments?: any;
    }): string;
    canPop(): boolean;
    maybePop(result?: any): boolean;
    popAndPushNamed(routeName: string, options?: {
        arguments?: any;
    }): void;
    popUntil(routeName: string): void;
    pushNamedAndRemoveUntil(state: any, newRouteName: string, untilRouteName: string): void;
    pushNamedAndRemoveUntilRoute(newRouteName: string, untilRouteName: string, options?: {
        arguments?: any;
    }): void;
}
declare class HybridHistory implements HybridHistoryInterface {
    get state(): any;
    get path(): any;
    back(): void;
    pushState(state: any, name: string): void;
    replaceState(state: any, name: string): void;
    restorablePopAndPushState(state: any, name: string): string;
    pop(result?: any): void;
    pushNamed(routeName: string, options?: {
        arguments?: any;
    }): void;
    pushReplacementNamed(routeName: string, options?: {
        arguments?: any;
    }): void;
    restorablePopAndPushNamed(routeName: string, options?: {
        arguments?: any;
    }): string;
    canPop(): boolean;
    maybePop(result?: any): boolean;
    popAndPushNamed(routeName: string, options?: {
        arguments?: any;
    }): void;
    popUntil(routeName: string): void;
    pushNamedAndRemoveUntil(state: any, newRouteName: string, untilRouteName: string): void;
    pushNamedAndRemoveUntilRoute(newRouteName: string, untilRouteName: string, options?: {
        arguments?: any;
    }): void;
}
export declare const hybridHistory: HybridHistory;
export {};
