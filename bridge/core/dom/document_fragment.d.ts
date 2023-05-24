import { Node } from './node';
import {ParentNode} from "./parent_node";

interface DocumentFragment extends Node, ParentNode {
  new(): DocumentFragment;
}
