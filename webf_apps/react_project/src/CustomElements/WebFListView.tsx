import { createComponent } from "../utils/CreateComponent";

interface WebFListViewProps {
  id?: string;
  className?: string;
  children?: React.ReactNode;
}

export const WebFListView = createComponent({
  tagName: 'webf-listview',
  displayName: 'WebFListView',
  events: {}
}) as React.ComponentType<WebFListViewProps & { ref?: React.Ref<HTMLUnknownElement> }>

export default WebFListView;