import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './BGPage.module.css';

interface GradientTextProps {
  text: string;
  className: string;
}

const GradientText: React.FC<GradientTextProps> = ({ text, className }) => {
  return (
    <div className={styles.container}>
      <div>{text}</div>
      <div className={`${styles[className]}`}></div>
    </div>
  );
};

export const BGPage: React.FC = () => {
  const gradientData = [
    {
      text: "background: linear-gradient(to top right, red, blue) with alpha",
      className: "backgroundGradientToTopRight",
    },
    {
      text: "background: linear-gradient(to top left, red, blue) with alpha",
      className: "backgroundGradientToTopLeft",
    },
    {
      text: "background: linear-gradient(to bottom right, red, blue) with alpha",
      className: "backgroundGradientToBottomRight",
    },
    {
      text: "background: linear-gradient(to bottom left, red, blue) with alpha",
      className: "backgroundGradientToBottomLeft",
    },
    {
      text: "background: linear-gradient(#ff0000, #0000ff) with alpha",
      className: "backgroundGradientHex",
    },
    {
      text: "background: linear-gradient(red, blue)",
      className: "backgroundGradient",
    },
    {
      text: "background: linear-gradient(to top, red, blue)",
      className: "backgroundGradientToTop",
    },
    {
      text: "background: linear-gradient(to bottom, red, blue)",
      className: "backgroundGradientToBottom",
    },
    {
      text: "background: linear-gradient(to left, red, blue)",
      className: "backgroundGradientToLeft",
    },
    {
      text: "background: linear-gradient(to right, red, blue)",
      className: "backgroundGradientToRight",
    },
    {
      text: "background: linear-gradient mix 1",
      className: "backgroundGradientGrad1Mix",
    },
    {
      text: "background: linear-gradient mix 2",
      className: "backgroundGradientGrad2Mix",
    },
    {
      text: "background: linear-gradient mix 3",
      className: "backgroundGradientGrad3Mix",
    },
    {
      text: "background: linear-gradient mix 4",
      className: "backgroundGradientGrad4Mix",
    },
    {
      text: "background: linear-gradient mix 5",
      className: "backgroundGradientGrad5Mix",
    },
    {
      text: "background: linear-gradient mix 6",
      className: "backgroundGradientGrad6Mix",
    },
    {
      text: "background: linear-gradient mix 7",
      className: "backgroundGradientGrad7Mix",
    },
    {
      text: "background: linear-gradient mix 8",
      className: "backgroundGradientGrad8Mix",
    },
  ];

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        {gradientData.map((item, index) => (
          <GradientText
            key={index}
            text={item.text}
            className={item.className}
          />
        ))}
      </WebFListView>
    </div>
  );
};