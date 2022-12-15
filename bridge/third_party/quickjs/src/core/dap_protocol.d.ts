// https://microsoft.github.io/debug-adapter-protocol/specification#Base_Protocol_Request

interface Request {
  /**
   * Sequence number of the message (also known as message ID). The `seq` for
   * the first message sent by a client or debug adapter is 1, and for each
   * subsequent message is 1 greater than the previous message sent by that
   * actor. `seq` can be used to order requests, responses, and events, and to
   * associate requests with their corresponding responses. For protocol
   * messages of type `request` the sequence number can be used to cancel the
   * request.
   */
  seq: int64;

  type: 'request';

  /**
   * The command to execute.
   */
  command: string;

  /**
   * Object containing arguments for the command.
   */
  arguments?: any;
}

interface AttachRequestArguments {
  /**
   * Arbitrary data from the previous, restarted session.
   * The data is sent as the `restart` attribute of the `terminated` event.
   * The client should leave the data intact.
   */
  __restart?: any;
}

interface ValueFormat {
  /**
   * Display the value in hex.
   */
  hex?: boolean;
}

interface EvaluateArguments {
  /**
   * The expression to evaluate.
   */
  expression: string;

  /**
   * Evaluate the expression in the scope of this stack frame. If not specified,
   * the expression is evaluated in the global scope.
   */
  frameId?: number;

  /**
   * The context in which the evaluate request is used.
   * Values:
   * 'watch': evaluate is called from a watch view context.
   * 'repl': evaluate is called from a REPL context.
   * 'hover': evaluate is called to generate the debug hover contents.
   * This value should only be used if the corresponding capability
   * `supportsEvaluateForHovers` is true.
   * 'clipboard': evaluate is called to generate clipboard contents.
   * This value should only be used if the corresponding capability
   * `supportsClipboardContext` is true.
   * 'variables': evaluate is called from a variables view context.
   * etc.
   */
  context?: string;

  /**
   * Specifies details on how to format the result.
   * The attribute is only honored by a debug adapter if the corresponding
   * capability `supportsValueFormattingOptions` is true.
   */
  format?: ValueFormat;
}

interface EvaluateRequest extends Request {
  command: 'evaluate';

  arguments: EvaluateArguments;
}

interface Event {
  /**
   * Sequence number of the message (also known as message ID). The `seq` for
   * the first message sent by a client or debug adapter is 1, and for each
   * subsequent message is 1 greater than the previous message sent by that
   * actor. `seq` can be used to order requests, responses, and events, and to
   * associate requests with their corresponding responses. For protocol
   * messages of type `request` the sequence number can be used to cancel the
   * request.
   */
  seq: int64;

  type: 'event';

  /**
   * Type of event.
   */
  event: string;

  /**
   * Event-specific information.
   */
  body?: any;
}

interface StoppedEventBody {
  /**
   * The reason for the event.
   * For backward compatibility this string is shown in the UI if the
   * `description` attribute is missing (but it must not be translated).
   * Values: 'step', 'breakpoint', 'exception', 'pause', 'entry', 'goto',
   * 'function breakpoint', 'data breakpoint', 'instruction breakpoint', etc.
   */
  reason: string;

  /**
   * The full reason for the event, e.g. 'Paused on exception'. This string is
   * shown in the UI as is and can be translated.
   */
  description?: string;

  /**
   * The thread which was stopped.
   */
  threadId?: number;

  /**
   * A value of true hints to the client that this event should not change the
   * focus.
   */
  preserveFocusHint?: boolean;

  /**
   * Additional information. E.g. if reason is `exception`, text contains the
   * exception name. This string is shown in the UI.
   */
  text?: string;

  /**
   * If `allThreadsStopped` is true, a debug adapter can announce that all
   * threads have stopped.
   * - The client should use this information to enable that all threads can
   * be expanded to access their stacktraces.
   * - If the attribute is missing or false, only the thread with the given
   * `threadId` can be expanded.
   */
  allThreadsStopped?: boolean;

  /**
   * Ids of the breakpoints that triggered the event. In most cases there is
   * only a single breakpoint but here are some examples for multiple
   * breakpoints:
   * - Different types of breakpoints map to the same location.
   * - Multiple source breakpoints get collapsed to the same instruction by
   * the compiler/runtime.
   * - Multiple function breakpoints with different function names map to the
   * same location.
   */
  hitBreakpointIds?: number[];
}

interface StoppedEvent extends Event {
  event: 'stopped';
  body: StoppedEventBody;
}

interface Response {
  /**
   * Sequence number of the message (also known as message ID). The `seq` for
   * the first message sent by a client or debug adapter is 1, and for each
   * subsequent message is 1 greater than the previous message sent by that
   * actor. `seq` can be used to order requests, responses, and events, and to
   * associate requests with their corresponding responses. For protocol
   * messages of type `request` the sequence number can be used to cancel the
   * request.
   */
  seq: int64;

  type: 'response';

  /**
   * Sequence number of the corresponding request.
   */
  request_seq: int64;

  /**
   * Outcome of the request.
   * If true, the request was successful and the `body` attribute may contain
   * the result of the request.
   * If the value is false, the attribute `message` contains the error in short
   * form and the `body` may contain additional information (see
   * `ErrorResponse.body.error`).
   */
  success: boolean;

  /**
   * The command requested.
   */
  command: string;

  /**
   * Contains the raw error in short form if `success` is false.
   * This raw error might be interpreted by the client and is not shown in the
   * UI.
   * Some predefined values exist.
   * Values:
   * 'cancelled': the request was cancelled.
   * 'notStopped': the request may be retried once the adapter is in a 'stopped'
   * state.
   * etc.
   */
  message?: 'cancelled' | 'notStopped' | string;

  /**
   * Contains request result if success is true and error details if success is
   * false.
   */
  body?: any;
}

interface VariablePresentationHint {
  /**
   * The kind of variable. Before introducing additional values, try to use the
   * listed values.
   * Values:
   * 'property': Indicates that the object is a property.
   * 'method': Indicates that the object is a method.
   * 'class': Indicates that the object is a class.
   * 'data': Indicates that the object is data.
   * 'event': Indicates that the object is an event.
   * 'baseClass': Indicates that the object is a base class.
   * 'innerClass': Indicates that the object is an inner class.
   * 'interface': Indicates that the object is an interface.
   * 'mostDerivedClass': Indicates that the object is the most derived class.
   * 'virtual': Indicates that the object is virtual, that means it is a
   * synthetic object introduced by the adapter for rendering purposes, e.g. an
   * index range for large arrays.
   * 'dataBreakpoint': Deprecated: Indicates that a data breakpoint is
   * registered for the object. The `hasDataBreakpoint` attribute should
   * generally be used instead.
   * etc.
   */
  kind?: 'property' | 'method' | 'class' | 'data' | 'event' | 'baseClass'
    | 'innerClass' | 'interface' | 'mostDerivedClass' | 'virtual'
    | 'dataBreakpoint' | string;

  /**
   * Set of attributes represented as an array of strings. Before introducing
   * additional values, try to use the listed values.
   * Values:
   * 'static': Indicates that the object is static.
   * 'constant': Indicates that the object is a constant.
   * 'readOnly': Indicates that the object is read only.
   * 'rawString': Indicates that the object is a raw string.
   * 'hasObjectId': Indicates that the object can have an Object ID created for
   * it.
   * 'canHaveObjectId': Indicates that the object has an Object ID associated
   * with it.
   * 'hasSideEffects': Indicates that the evaluation had side effects.
   * 'hasDataBreakpoint': Indicates that the object has its value tracked by a
   * data breakpoint.
   * etc.
   */
  attributes?: ('static' | 'constant' | 'readOnly' | 'rawString' | 'hasObjectId'
    | 'canHaveObjectId' | 'hasSideEffects' | 'hasDataBreakpoint' | string)[];

  /**
   * Visibility of variable. Before introducing additional values, try to use
   * the listed values.
   * Values: 'public', 'private', 'protected', 'internal', 'final', etc.
   */
  visibility?: 'public' | 'private' | 'protected' | 'internal' | 'final' | string;

  /**
   * If true, clients can present the variable with a UI that supports a
   * specific gesture to trigger its evaluation.
   * This mechanism can be used for properties that require executing code when
   * retrieving their value and where the code execution can be expensive and/or
   * produce side-effects. A typical example are properties based on a getter
   * function.
   * Please note that in addition to the `lazy` flag, the variable's
   * `variablesReference` is expected to refer to a variable that will provide
   * the value through another `variable` request.
   */
  lazy?: boolean;
}

interface EvaluateResponseBody {
  /**
   * The result of the evaluate request.
   */
  result: string;

  /**
   * The type of the evaluate result.
   * This attribute should only be returned by a debug adapter if the
   * corresponding capability `supportsVariableType` is true.
   */
  type?: string;

  /**
   * Properties of an evaluate result that can be used to determine how to
   * render the result in the UI.
   */
  presentationHint?: VariablePresentationHint;

  /**
   * If `variablesReference` is > 0, the evaluate result is structured and its
   * children can be retrieved by passing `variablesReference` to the
   * `variables` request as long as execution remains suspended. See 'Lifetime
   * of Object References' in the Overview section for details.
   */
  variablesReference: number;

  /**
   * The number of named child variables.
   * The client can use this information to present the variables in a paged
   * UI and fetch them in chunks.
   * The value should be less than or equal to 2147483647 (2^31-1).
   */
  namedVariables?: number;

  /**
   * The number of indexed child variables.
   * The client can use this information to present the variables in a paged
   * UI and fetch them in chunks.
   * The value should be less than or equal to 2147483647 (2^31-1).
   */
  indexedVariables?: number;

  /**
   * A memory reference to a location appropriate for this result.
   * For pointer type eval results, this is generally a reference to the
   * memory address contained in the pointer.
   * This attribute should be returned by a debug adapter if corresponding
   * capability `supportsMemoryReferences` is true.
   */
  memoryReference?: string;
}

interface EvaluateResponse extends Response {
  body: EvaluateResponseBody;
}
