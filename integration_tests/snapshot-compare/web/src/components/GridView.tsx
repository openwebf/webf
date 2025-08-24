import React from 'react';
import { ComparisonResult } from '../types';

interface GridViewProps {
  comparison: ComparisonResult;
}

const GridView: React.FC<GridViewProps> = ({ comparison }) => {
  return (
    <div className="images">
      <div className="image-container">
        <div className="image-label">WebF Snapshot</div>
        <div className="image-wrapper">
          <img src={comparison.webfSnapshot} alt="WebF Snapshot" />
        </div>
      </div>
      <div className="image-container">
        <div className="image-label">Chrome Snapshot</div>
        <div className="image-wrapper">
          <img src={comparison.chromeSnapshot} alt="Chrome Snapshot" />
        </div>
      </div>
      <div className="image-container">
        <div className="image-label">Difference</div>
        <div className="image-wrapper">
          <img src={comparison.diffImage} alt="Difference" />
        </div>
      </div>
    </div>
  );
};

export default GridView;