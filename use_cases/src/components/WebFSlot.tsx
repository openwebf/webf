import React from 'react';

interface WebFSlotProps {
  name: string;
  id?: string;
  children: React.ReactNode;
  className?: string;
  style?: React.CSSProperties;
}

/**
 * WebFSlot component for WebF slot functionality
 * This component renders a div with slotName attribute for WebF components that support slots
 */
export const WebFSlot: React.FC<WebFSlotProps> = ({ name, children, className, style, id }) => {
  // Apply default minimal padding reset for slot containers
  const defaultStyle: React.CSSProperties = {
    margin: 0,
    padding: 0,
    ...style
  };

  return (
    <div
      {...{ slotName: name } as any} // Type assertion to bypass TypeScript checking
      className={className}
      style={defaultStyle}
      id={id}
    >
      {children}
    </div>
  );
};
