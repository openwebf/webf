import React from 'react';
import { ComparisonResult, ViewMode } from '../types';
import ComparisonItem from './ComparisonItem';

interface ComparisonListProps {
  comparisons: ComparisonResult[];
  viewMode: ViewMode;
  onOpenCode: (specFile: string) => void;
}

const ComparisonList: React.FC<ComparisonListProps> = ({ comparisons, viewMode, onOpenCode }) => {
  if (comparisons.length === 0) {
    return <div className="error">No comparisons found</div>;
  }

  return (
    <div className="comparisons-list">
      {comparisons.map((comparison, index) => (
        <ComparisonItem
          key={`${comparison.specFile}-${index}`}
          comparison={comparison}
          viewMode={viewMode}
          index={index}
          onOpenCode={onOpenCode}
        />
      ))}
    </div>
  );
};

export default ComparisonList;