import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './ClipPathPage.module.css';

interface ShapeDemoProps {
  title: string;
  className: string;
}

const ShapeDemo: React.FC<ShapeDemoProps> = ({ title, className }) => {
  return (
    <div className={styles.card}>
      <div className={styles.cardTitle}>{title}</div>
      <div className={`${styles.shapeContainer} ${className}`}>
        <div className={styles.text}>WEBF</div>
      </div>
    </div>
  );
};

export const ClipPathPage: React.FC = () => {
  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <ShapeDemo title="Inset (Rectangle)" className={styles.clipInset} />
        <ShapeDemo title="Circle" className={styles.clipCircle} />
        <ShapeDemo title="Ellipse" className={styles.clipEllipse} />
        <ShapeDemo title="Polygon (Triangle)" className={styles.clipTriangle} />
        <ShapeDemo title="Polygon (Rhombus)" className={styles.clipRhombus} />
        <ShapeDemo title="Polygon (Star)" className={styles.clipStar} />
        <ShapeDemo title="Polygon (Trapezoid)" className={styles.clipTrapezoid} />
        <ShapeDemo title="Polygon (Parallelogram)" className={styles.clipParallelogram} />
      </WebFListView>
    </div>
  );
};
