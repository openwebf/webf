import React, { useRef, useState, useEffect } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { FlutterCupertinoIcon, FlutterCupertinoSwitch, FlutterCupertinoContextMenu } from '@openwebf/react-cupertino-ui';
import styles from './ContextMenuPage.module.css';

export const ContextMenuPage: React.FC = () => {
  const menu0Ref = useRef<any>(null);
  const menu1Ref = useRef<any>(null);
  const menu2Ref = useRef<any>(null);
  const menu3Ref = useRef<any>(null);
  const menu4Ref = useRef<any>(null);
  const menu5Ref = useRef<any>(null);

  const [menu1HasActions, setMenu1HasActions] = useState(true);

  const menu1DefaultActions = [
    { text: 'Default Action (menu1)', icon: 'share', event: 'defaultAction' },
    { text: 'Delete (menu1)', icon: 'delete', event: 'delete', destructive: true }
  ];

  const setMenu1Actions = () => {
    if (menu1Ref.current) {
      const actionsToSet = menu1HasActions ? menu1DefaultActions : [];
      console.log(`Setting actions for menu1 (hasActions: ${menu1HasActions}):`, actionsToSet);
      menu1Ref.current.setActions(actionsToSet);
    }
  };

  const handleMenu1SwitchChange = (event: any) => {
    const newValue = event.detail;
    console.log('Menu 1 Switch changed:', newValue);
    setMenu1HasActions(newValue);
  };

  useEffect(() => {
    setMenu1Actions();
  }, [menu1HasActions]);

  useEffect(() => {
    const setupMenus = () => {
      // Example 0: No setActions called, initially no menu
      // (No action needed for menu0)

      // Example 1: Switch controls, set initial state
      setMenu1Actions();

      // Example 2: Custom menu items 
      if (menu2Ref.current) {
        menu2Ref.current.setActions([
          { text: "Share", icon: "share", event: "share" },
          { text: "Favorite", icon: "heart", event: "favorite" }
        ]);
      }

      // Example 3: With destructive action
      if (menu3Ref.current) {
        menu3Ref.current.setActions([
          { text: "Open", icon: "doc", event: "open" },
          { text: "Edit", icon: "pencil", event: "edit" },
          { text: "Delete", icon: "delete", event: "delete", destructive: true }
        ]);
      }

      // Example 4: With default action
      if (menu4Ref.current) {
        menu4Ref.current.setActions([
          { text: "Call", icon: "phone", event: "call", default: true },
          { text: "Message", icon: "chat_bubble", event: "message" },
          { text: "Email", icon: "mail", event: "email" }
        ]);
      }

      // Example 5: Set empty actions (previously menu6)
      if (menu5Ref.current) { 
        console.log('Setting empty actions for menu5');
        menu5Ref.current.setActions([]);
      }
    };

    // Setup menus after component mounts
    const timer = setTimeout(setupMenus, 100);
    return () => clearTimeout(timer);
  }, []);

  // Event Handler
  const onSelect = (e) => console.log('Select event', e.detail);

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.componentSection}>
          <div className={styles.sectionTitle}>Context Menu</div>
          <div className={styles.componentBlock}>
            
            {/* Example 0: No setActions called (initially no menu) */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>No setActions called (initially no menu)</div>
              <div className={styles.menuContainer}>
                <FlutterCupertinoContextMenu ref={menu0Ref}>
                  <div className={styles.previewBox}>
                    <FlutterCupertinoIcon type="star" style={{fontSize: '48px'}} />
                    <div className={styles.previewText}>Initial no menu</div>
                  </div>
                </FlutterCupertinoContextMenu>
              </div>
            </div>

            {/* Example 1: Controlled by Switch */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Switch controls menu configuration</div>
              <div className={styles.controlRow}>
                <span>Configure menu:</span>
                <FlutterCupertinoSwitch 
                  checked={menu1HasActions}
                  onChange={handleMenu1SwitchChange}
                />
              </div>
              <div className={styles.menuContainer}>
                <FlutterCupertinoContextMenu 
                  ref={menu1Ref} 
                  onSelect={onSelect}
                >
                  <div className={styles.previewBox}>
                    <FlutterCupertinoIcon type="photo" style={{fontSize: '48px'}} />
                    <div className={styles.previewText}>Switch controlled</div>
                  </div>
                </FlutterCupertinoContextMenu>
              </div>
            </div>

            {/* Example 2: Custom Menu Items */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Custom Menu Items</div>
              <div className={styles.menuContainer}>
                <FlutterCupertinoContextMenu
                  onSelect={onSelect}
                  ref={menu2Ref} 
                >
                  <div className={styles.previewBox}>
                    <FlutterCupertinoIcon type="heart" style={{fontSize: '48px'}} />
                    <div className={styles.previewText}>Custom menu item</div>
                  </div>
                </FlutterCupertinoContextMenu>
              </div>
            </div>

            {/* Example 3: With Destructive Action */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>With Destructive Action</div>
              <div className={styles.menuContainer}>
                <FlutterCupertinoContextMenu 
                  ref={menu3Ref} 
                  enableHapticFeedback 
                  onSelect={onSelect}
                >
                  <div className={styles.previewBox}>
                    <FlutterCupertinoIcon type="doc_text" style={{fontSize: '48px'}} />
                    <div className={styles.previewText}>Document action</div>
                  </div>
                </FlutterCupertinoContextMenu>
              </div>
            </div>

            {/* Example 4: With Default Action */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>With Default Action</div>
              <div className={styles.menuContainer}>
                <FlutterCupertinoContextMenu 
                  ref={menu4Ref} 
                  enableHapticFeedback 
                  onSelect={onSelect}
                >
                  <div className={styles.previewBox}>
                    <FlutterCupertinoIcon type="person_circle" style={{fontSize: '48px'}} />
                    <div className={styles.previewText}>Contact</div>
                  </div>
                </FlutterCupertinoContextMenu>
              </div>
            </div>

            {/* Example 5: setActions called with empty array */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>setActions([]) (no menu)</div>
              <div className={styles.menuContainer}>
                <FlutterCupertinoContextMenu 
                  ref={menu5Ref}
                  onSelect={onSelect}
                >
                  <div className={styles.previewBox}>
                    <FlutterCupertinoIcon type="xmark_circle" style={{fontSize: '48px'}} />
                    <div className={styles.previewText}>Empty menu</div>
                  </div>
                </FlutterCupertinoContextMenu>
              </div>
            </div>

          </div>
        </div>
      </WebFListView>
    </div>
  );
};