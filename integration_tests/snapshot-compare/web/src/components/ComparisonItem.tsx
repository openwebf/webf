import React from 'react';
import { ComparisonResult, ViewMode } from '../types';
import GridView from './GridView';
import SliderView from './SliderView';

interface ComparisonItemProps {
  comparison: ComparisonResult;
  viewMode: ViewMode;
  index: number;
  onOpenCode: (specFile: string) => void;
}

const ComparisonItem: React.FC<ComparisonItemProps> = ({ 
  comparison, 
  viewMode, 
  index, 
  onOpenCode 
}) => {
  const matchClass = comparison.percentDifference === 0 ? 'perfect-match' :
                    comparison.percentDifference < 1 ? 'close-match' : 'different';
  const matchText = comparison.percentDifference === 0 ? 'Perfect Match' :
                   comparison.percentDifference < 1 ? 'Close Match' : 'Different';

  return (
    <div className="comparison">
      <div className="comparison-header">
        <div>
          <div className="test-name">{comparison.testDescription}</div>
          <div className="spec-file">{comparison.specFile}</div>
        </div>
        <div className="diff-stats">
          <div className="stat">
            Difference: <span className="stat-value">{comparison.percentDifference.toFixed(2)}%</span>
          </div>
          <div className="stat">
            Pixels: <span className="stat-value">{comparison.pixelDifference.toLocaleString()}</span>
          </div>
          <div className="stat">
            Size: <span className="stat-value">{comparison.width}×{comparison.height}</span>
          </div>
          <div className={`match-badge ${matchClass}`}>{matchText}</div>
          <button 
            className="code-btn" 
            onClick={() => onOpenCode(comparison.specFile)}
          >
            <span style={{ fontFamily: 'monospace' }}>&lt;/&gt;</span> Code
          </button>
        </div>
      </div>
      
      {viewMode === 'grid' ? (
        <GridView comparison={comparison} />
      ) : (
        <SliderView comparison={comparison} index={index} />
      )}
    </div>
  );
};

export default ComparisonItem;