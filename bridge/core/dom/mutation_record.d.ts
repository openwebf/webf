import {NodeList} from "./node_list";
import {Node} from "./node";

interface MutationRecord {
  readonly type: string;
  readonly target: Node;
  readonly addedNodes: NodeList;
  readonly removedNodes: NodeList;
  readonly previousSibling?: Node;
  readonly nextSibling?: Node;
  readonly attributeName?: string;
  readonly attributeNamespace?: string;
  readonly oldValue?: string;

  new(): void;
}