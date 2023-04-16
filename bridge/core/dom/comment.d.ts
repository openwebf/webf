import {CharacterData} from "./character_data";

export interface Comment extends CharacterData {
  new(data: string | null): Comment;
}
