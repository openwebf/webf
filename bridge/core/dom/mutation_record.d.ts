import {NodeList} from "./node_list";
import {Node} from "./node";

interface MutationRecord {
  readonly type: string;
  readonly target: Node;
  readonly addedNodes: NodeList;
  readonly removedNodes: NodeList;
  readonly previousSibling: Node | null;
  readonly nextSibling: Node | null;
  readonly attributeName: string | null;
  readonly attributeNamespace: string | null;
  readonly oldValue: string | null;

  new(): void;
}