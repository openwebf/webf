import React, { useRef, useEffect, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './MutationObserverPage.module.css';

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
      { element: attributeTargetRef.current, config: { attributes: true, attributeOldValue: true } },
      { element: childListTargetRef.current, config: { childList: true } },
      { element: subtreeTargetRef.current, config: { childList: true, attributes: true, subtree: true } }
    ];

    elements.forEach(({ element, config }) => {
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
    element.className = styles.dynamicElement;
    subtreeTargetRef.current?.appendChild(element);
  };

  const clearDynamicElements = () => {
    const dynamicElements = subtreeTargetRef.current?.querySelectorAll(`.${styles.dynamicElement}`);
    dynamicElements?.forEach(el => el.remove());
  };


  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.componentSection}>
          <div className={styles.sectionTitle}>MutationObserver API</div>
          <div className={styles.componentBlock}>
            
            {/* Attribute Mutations */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Attribute Mutations</div>
              <div className={styles.itemDesc}>Observer tracks changes to element attributes</div>
              <div
                ref={attributeTargetRef}
                className={styles.attributeTarget}
                style={{ backgroundColor: attributeColor }}
              >
                <div className={styles.targetContent}>
                  Background Color: {attributeColor}
                </div>
              </div>
              <div className={styles.controls}>
                <button className={styles.actionButton} onClick={changeAttributeColor}>
                  Change Color
                </button>
              </div>
            </div>

            {/* Child List Mutations */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Child List Mutations</div>
              <div className={styles.itemDesc}>Observer tracks addition and removal of child elements</div>
              <div ref={childListTargetRef} className={styles.todoContainer}>
                {todoItems.map((item, index) => (
                  <div key={index} className={styles.todoItem}>
                    <span className={styles.todoText}>{item}</span>
                    <div 
                      className={styles.removeButton}
                      onClick={() => removeTodoItem(index)}
                    >
                      ×
                    </div>
                  </div>
                ))}
              </div>
              <div className={styles.controls}>
                <input
                  type="text"
                  value={currentInput}
                  onChange={(e) => setCurrentInput(e.target.value)}
                  placeholder="Add new todo"
                  className={styles.textInput}
                  onKeyDown={(e) => e.key === 'Enter' && addTodoItem()}
                />
                <button className={styles.actionButton} onClick={addTodoItem}>
                  Add Item
                </button>
              </div>
            </div>


            {/* Subtree Mutations */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Subtree Mutations</div>
              <div className={styles.itemDesc}>Observer tracks changes throughout the entire subtree</div>
              <div ref={subtreeTargetRef} className={styles.subtreeContainer}>
                <div className={styles.subtreeHeader}>Subtree Container</div>
                <div className={styles.dynamicContent}>
                  {/* Dynamic elements will be added here */}
                </div>
              </div>
              <div className={styles.controls}>
                <button className={styles.actionButton} onClick={addRandomElement}>
                  Add Element
                </button>
                <button className={styles.actionButton} onClick={clearDynamicElements}>
                  Clear All
                </button>
              </div>
            </div>

            {/* Mutations Log */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Mutations Log</div>
              <div className={styles.itemDesc}>Real-time log of all observed mutations (last 50 entries)</div>
              <div className={styles.mutationsLog}>
                {mutations.map((mutation) => (
                  <div key={mutation.id} className={styles.mutationEntry}>
                    <div className={styles.mutationHeader}>
                      <span className={`${styles.mutationType} ${styles[mutation.type]}`}>
                        {mutation.type}
                      </span>
                      <span className={styles.mutationTime}>{mutation.timestamp}</span>
                    </div>
                    <div className={styles.mutationDetails}>
                      <span className={styles.mutationTarget}>{mutation.target}</span>
                      <span className={styles.mutationValue}>{mutation.details}</span>
                    </div>
                  </div>
                ))}
                {mutations.length === 0 && (
                  <div className={styles.logEmpty}>Interact with elements above to see mutations...</div>
                )}
              </div>
            </div>

          </div>
        </div>
      </WebFListView>
    </div>
  );
};