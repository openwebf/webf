import React, {useRef, useEffect, useState} from 'react';
import {WebFListView} from '@openwebf/react-core-ui';

interface MutationLog {
  id: string;
  timestamp: string;
  type: string;
  target: string;
  details: string;
}

export const MutationObserverPage: React.FC = () => {
  const [mutations, setMutations] = useState<MutationLog[]>([]);
  const [todoItems, setTodoItems] = useState<string[]>(['Learn ResizeObserver', 'Master MutationObserver']);
  const [currentInput, setCurrentInput] = useState('');
  const [attributeColor, setAttributeColor] = useState('#2196F3');
  const [isLogCollapsed, setIsLogCollapsed] = useState(false);

  const attributeTargetRef = useRef<HTMLDivElement>(null);
  const childListTargetRef = useRef<HTMLDivElement>(null);
  const subtreeTargetRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const mutationObserver = new MutationObserver((mutationsList) => {
      const newMutations: MutationLog[] = [];

      mutationsList.forEach((mutation, index) => {
        const timestamp = new Date().toLocaleTimeString();
        const target = mutation.target.nodeName + (
          mutation.target instanceof Element && mutation.target.className
            ? `.${mutation.target.className}`
            : ''
        );

        let details = '';
        switch (mutation.type) {
          case 'attributes':
            const attrName = mutation.attributeName;
            const attrValue = mutation.target instanceof Element
              ? mutation.target.getAttribute(attrName || '') || ''
              : '';
            details = `${attrName}: "${attrValue}"`;
            break;
          case 'childList':
            const added = mutation.addedNodes.length;
            const removed = mutation.removedNodes.length;
            details = `+${added} -${removed} nodes`;
            break;
        }

        newMutations.push({
          id: `${Date.now()}-${index}`,
          timestamp,
          type: mutation.type,
          target,
          details
        });
      });

      setMutations(prev => [...newMutations, ...prev].slice(0, 50));
    });

    // Observe multiple elements with different configurations
    const elements = [
      {element: attributeTargetRef.current, config: {attributes: true, attributeOldValue: true}},
      {element: childListTargetRef.current, config: {childList: true}},
      {element: subtreeTargetRef.current, config: {childList: true, attributes: true, subtree: true}}
    ];

    elements.forEach(({element, config}) => {
      if (element) {
        mutationObserver.observe(element, config);
      }
    });

    return () => mutationObserver.disconnect();
  }, []);

  const addTodoItem = () => {
    if (currentInput.trim()) {
      setTodoItems(prev => [...prev, currentInput.trim()]);
      setCurrentInput('');
    }
  };

  const removeTodoItem = (index: number) => {
    setTodoItems(prev => prev.filter((_, i) => i !== index));
  };

  const changeAttributeColor = () => {
    const colors = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63', '#9C27B0'];
    const currentIndex = colors.indexOf(attributeColor);
    const nextColor = colors[(currentIndex + 1) % colors.length];
    setAttributeColor(nextColor);
  };

  const addRandomElement = () => {
    const element = document.createElement('div');
    element.textContent = `Dynamic element ${Date.now()}`;
    element.className = 'dynamic-element px-3 py-2 bg-gradient-to-tr from-indigo-500 to-purple-600 text-white rounded text-xs font-medium mr-2 mb-2';
    subtreeTargetRef.current?.appendChild(element);
  };

  const clearDynamicElements = () => {
    const dynamicElements = subtreeTargetRef.current?.querySelectorAll('.dynamic-element');
    dynamicElements?.forEach(el => el.remove());
  };

  const clearMutations = () => {
    setMutations([]);
  };


  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6 pb-40">
          <div className="flex flex-col gap-6">

            {/* Attribute Mutations */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary">Attribute Mutations</div>
              <div className="text-sm text-fg-secondary mb-3">Observer tracks changes to element attributes</div>
              <div
                ref={attributeTargetRef}
                className="w-full h-30 h-[120px] rounded flex items-center justify-center mb-4 transition-colors"
                style={{backgroundColor: attributeColor}}
              >
                <div className="text-white text-lg font-semibold drop-shadow">Background Color: {attributeColor}</div>
              </div>
              <div className="flex gap-2 flex-wrap items-center">
                <button className="px-3 py-2 rounded bg-black text-white hover:bg-neutral-700"
                        onClick={changeAttributeColor}>Change Color
                </button>
              </div>
            </div>

            {/* Child List Mutations */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary">Child List Mutations</div>
              <div className="text-sm text-fg-secondary mb-3">Observer tracks addition and removal of child elements
              </div>
              <div ref={childListTargetRef}
                   className="min-h-[120px] border-2 border-dashed border-line rounded p-4 mb-3 bg-surface">
                {todoItems.map((item, index) => (
                  <div key={index}
                       className="flex items-center justify-between p-3 mb-2 bg-white rounded border border-line hover:border-sky-600 hover:-translate-y-px hover:shadow transition">
                    <span className="flex-1 text-sm text-fg-primary">{item}</span>
                    <button className="w-6 h-6 rounded-full bg-red-500 text-white flex items-center justify-center"
                            onClick={() => removeTodoItem(index)}>×
                    </button>
                  </div>
                ))}
              </div>
              <div className="flex gap-2 flex-wrap items-center">
                <input
                  type="text"
                  value={currentInput}
                  onChange={(e) => setCurrentInput(e.target.value)}
                  placeholder="Add new todo"
                  className="flex-1 min-w-[220px] rounded border-2 border-line px-3 py-2 bg-surface focus:border-sky-600 outline-none"
                  onKeyDown={(e) => e.key === 'Enter' && addTodoItem()}
                />
                <button className="px-3 py-2 rounded bg-black text-white hover:bg-neutral-700" onClick={addTodoItem}>Add
                  Item
                </button>
              </div>
            </div>


            {/* Subtree Mutations */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-3">
              <div className="text-lg font-medium text-fg-primary">Subtree Mutations</div>
              <div className="text-sm text-fg-secondary mb-3">Observer tracks changes throughout the entire subtree
              </div>
              <div ref={subtreeTargetRef} className="min-h-[120px] border-2 border-line rounded p-4 mb-3 bg-surface">
                <div className="text-fg-primary font-medium mb-2 pb-2 border-b border-line">Subtree Container</div>
                <div className="flex flex-wrap">
                  {/* Dynamic elements will be added here */}
                </div>
              </div>
              <div className="flex gap-2 flex-wrap items-center">
                <button className="px-3 py-2 rounded bg-black text-white hover:bg-neutral-700"
                        onClick={addRandomElement}>Add Element
                </button>
                <button className="px-3 py-2 rounded bg-black text-white hover:bg-neutral-700"
                        onClick={clearDynamicElements}>Clear All
                </button>
              </div>
            </div>
          </div>
      </WebFListView>

      {/* Fixed Bottom Mutations Log Panel */}
      <div className="fixed bottom-0 left-0 right-0 z-50">
        <div className="max-w-4xl mx-auto px-3 md:px-6">
          <div className="bg-surface-secondary border border-line rounded-t-xl shadow-xl">
            <div className="flex items-center justify-between p-3">
              <div className="text-lg font-medium text-fg-primary">Mutations Log</div>
              <div className="flex items-center gap-2">
                <button
                  className="px-3 py-1.5 rounded bg-black text-white hover:bg-neutral-700 text-sm"
                  onClick={clearMutations}
                >
                  Clear
                </button>
                <button
                  className="px-3 py-1.5 rounded border border-line bg-white hover:bg-neutral-50 text-sm"
                  onClick={() => setIsLogCollapsed(v => !v)}
                  aria-expanded={!isLogCollapsed}
                  aria-controls="mutations-log-panel"
                >
                  {isLogCollapsed ? 'Expand' : 'Fold'}
                </button>
              </div>
            </div>
            <div
              id="mutations-log-panel"
              className={`border-t border-line rounded-b-xl overflow-hidden transition-all duration-300 ease-in-out ${
                isLogCollapsed ? 'max-h-0 opacity-0' : 'max-h-[24vh] opacity-100'
              }`}
            >
              <div className="bg-surface p-4 overflow-y-auto max-h-[24vh]">
                {mutations.map((mutation) => (
                  <div key={mutation.id} className="p-3 mb-2 bg-white rounded border">
                    <div className="flex items-center justify-between mb-1">
                      <span
                        className={`px-2 py-1 rounded text-xs font-semibold uppercase tracking-wide ${
                          mutation.type === 'attributes'
                            ? 'bg-blue-100 text-blue-700'
                            : mutation.type === 'childList'
                            ? 'bg-green-100 text-green-700'
                            : 'bg-amber-100 text-amber-600'
                        }`}
                      >
                        {mutation.type}
                      </span>
                      <span className="text-xs text-fg-secondary font-mono">{mutation.timestamp}</span>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-sm font-medium font-mono text-fg-primary">{mutation.target}</span>
                      <span className="text-sm italic text-fg-secondary">{mutation.details}</span>
                    </div>
                  </div>
                ))}
                {mutations.length === 0 && (
                  <div className="text-center text-fg-secondary italic py-10">
                    Interact with elements above to see mutations...
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
