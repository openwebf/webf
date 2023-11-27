import {Node} from "./node";
import {MutationObserverInit} from "./mutation_observer_init";
import {MutationRecord} from "./mutation_record";

interface MutationObserver {
  new(mutationCallback: Function): MutationObserver;
  observe(targe: Node, options?: MutationObserverInit): void;
  disconnect(): void;
  takeRecords(): MutationRecord[];
}