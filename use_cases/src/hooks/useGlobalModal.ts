// Global modal state using a simple callback pattern (no CustomEvent dependency)

export interface GlobalModalPayload {
  title: string;
  body: string;
}

type ModalListener = (payload: GlobalModalPayload | null) => void;

let _listener: ModalListener | null = null;

export function registerGlobalModalListener(listener: ModalListener) {
  _listener = listener;
  return () => { _listener = null; };
}

export function showGlobalModal(title: string, body: string) {
  _listener?.({ title, body });
}

export function hideGlobalModal() {
  _listener?.(null);
}
