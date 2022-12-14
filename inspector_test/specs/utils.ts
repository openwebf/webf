let _seq = 0;

export function wrapVScodeExtension(data: any) {
  return {
    vscode: true,
    data: data
  }
}

export function buildRequest(command: string, args: any) {
  return wrapVScodeExtension({
    arguments: args,
    type: 'request',
    command: command,
    seq: _seq++
  });
}

export function buildBreakpointMessage(path: string, breakpoints: { line: number, column: number }[]) {
  return JSON.stringify(wrapVScodeExtension({
    type: 'breakpoints',
    breakpoints: {
      path: path,
      breakpoints: breakpoints
    }
  }))
}

export function buildStopOnException(enabled: boolean = false) {
  return JSON.stringify(wrapVScodeExtension({
    type: 'stopOnException',
    stopOnException: enabled
  }))
}

export function buildContinue() {
  return JSON.stringify(wrapVScodeExtension({
    type: 'continue'
  }));
}

export function checkEvent(event: any, type: string) {
  expect(event.type).toBe('event');
  expect(event.event.type).toBe(type);
}
