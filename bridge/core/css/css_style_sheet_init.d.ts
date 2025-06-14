// @ts-ignore
import {MediaList} from "./media_list";

// @ts-ignore
@Dictionary()
export interface CSSStyleSheetInit {
  media?: string | MediaList;
  disabled?: boolean;
  alternate?: boolean;
  title?: string;
}
