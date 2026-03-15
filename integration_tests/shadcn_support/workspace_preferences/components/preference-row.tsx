/** @jsxImportSource react */
import React from 'react';
import { cn } from '../../../specs/shadcn/_shared/cn';
import type { PreferenceItem } from '../types';

type PreferenceRowProps = {
  item: PreferenceItem;
  onToggle: (id: PreferenceItem['id']) => void;
};

export function PreferenceRow({ item, onToggle }: PreferenceRowProps) {
  return (
    <div className="shadcn-row">
      <div className="shadcn-row-copy">
        <p className="shadcn-card-title">{item.title}</p>
        <p className="shadcn-card-description">{item.description}</p>
      </div>
      <button
        aria-pressed={item.enabled}
        className={cn('shadcn-toggle-pill')}
        data-state={item.enabled ? 'on' : 'off'}
        data-testid={`toggle-${item.id}`}
        onClick={() => onToggle(item.id)}
        type="button"
      >
        {item.enabled ? 'On' : 'Off'}
      </button>
    </div>
  );
}
