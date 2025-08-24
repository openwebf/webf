import React from 'react';
import { ViewMode } from '../types';

interface ViewModeToggleProps {
  viewMode: ViewMode;
  onViewModeChange: (mode: ViewMode) => void;
}

const ViewModeToggle: React.FC<ViewModeToggleProps> = ({ viewMode, onViewModeChange }) => {
  return (
    <div className="controls">
      <button 
        className={`toggle-btn ${viewMode === 'grid' ? 'active' : ''}`}
        onClick={() => onViewModeChange('grid')}
      >
        Grid View
      </button>
      <button 
        className={`toggle-btn ${viewMode === 'slider' ? 'active' : ''}`}
        onClick={() => onViewModeChange('slider')}
      >
        Slider View
      </button>
    </div>
  );
};

export default ViewModeToggle;