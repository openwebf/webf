import {Element} from "../dom/element";

interface HTMLAnchorElement extends Element {
  target: SupportAsync<DartImpl<string>>;
  accessKey: DartImpl<string>;
  // accessKey: SupportAsync<DartImpl<string>>;
  download: DartImpl<string>;
  // download: SupportAsync<DartImpl<string>>;
  ping: DartImpl<string>;
  // ping: SupportAsync<DartImpl<string>>;
  rel: SupportAsync<DartImpl<string>>;
  type: SupportAsync<DartImpl<string>>;
  text: DartImpl<string>;
  // text: SupportAsync<DartImpl<string>>;
  href: SupportAsync<DartImpl<string>>;
  readonly origin: DartImpl<string>;
  // readonly origin: SupportAsync<DartImpl<string>>;
  protocol: SupportAsync<DartImpl<string>>;
  username: DartImpl<string>;
  // username: SupportAsync<DartImpl<string>>;
  password: DartImpl<string>;
  // password: SupportAsync<DartImpl<string>>;
  host: SupportAsync<DartImpl<string>>;
  hostname: SupportAsync<DartImpl<string>>;
  port: SupportAsync<DartImpl<string>>;
  pathname: SupportAsync<DartImpl<string>>;
  search: SupportAsync<DartImpl<string>>;
  hash: SupportAsync<DartImpl<string>>;
  new(): void;
}
