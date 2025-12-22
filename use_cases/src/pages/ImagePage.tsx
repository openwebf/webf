import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './ImagePage.module.css';

export const ImagePage: React.FC = () => {
  // Sample image data
  const imageExamples = {
    png: {
      title: 'PNG Format',
      description: 'PNG (Portable Network Graphics) supports transparency, suitable for icons and images requiring transparent backgrounds',
      samples: [
        {
          name: 'PNG Logo',
          url: 'https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/w3c-icon.png',
          desc: 'W3C Logo PNG format'
        }
      ]
    },
    jpg: {
      title: 'JPG/JPEG Format',
      description: 'JPEG format has high compression ratio, suitable for photos and complex images',
      samples: [
        {
          name: 'JPEG Photo',
          url: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
          desc: 'High-quality landscape photo'
        }
      ]
    },
    webp: {
      title: 'WebP Format',
      description: 'WebP is a modern image format that provides better compression ratio and quality balance',
      samples: [
        {
          name: 'WebP Sample',
          url: 'https://www.gstatic.com/webp/gallery/1.webp',
          desc: 'WebP format sample image'
        }
      ]
    },
    svg: {
      title: 'SVG Format',
      description: 'SVG is a vector graphics format that can be scaled infinitely without distortion, suitable for icons and simple graphics',
      samples: [
        {
          name: 'SVG Icon',
          url: 'https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/410.svg',
          desc: 'SVG vector icon'
        }
      ]
    },
    gif: {
      title: 'GIF Format',
      description: 'GIF supports animation, suitable for simple dynamic image display',
      samples: [
        {
          name: 'Loading GIF',
          url: 'https://media.giphy.com/media/3oEjI6SIIHBdRxXI40/giphy.gif',
          desc: 'Loading animation GIF'
        },
        {
          name: 'Animated Icon',
          url: 'https://media.giphy.com/media/l3vR85PnGsBwu1PFK/giphy.gif',
          desc: 'Animated icon display'
        }
      ]
    }
  };

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.componentSection}>
          <div className={styles.sectionTitle}>Image Format Showcase</div>
          <div className={styles.componentBlock}>

            {/* Loop through all image formats */}
            {Object.entries(imageExamples).map(([format, data]) => (
              <div key={format} className={styles.componentItem}>
                <div className={styles.itemLabel}>{data.title}</div>
                <div className={styles.itemDesc}>{data.description}</div>
                <div className={styles.imageGrid}>
                  {data.samples.map((sample, index) => (
                    <div key={index} className={styles.imageCard}>
                      <div className={styles.imageContainer}>
                        <img
                          src={sample.url}
                          alt={sample.name}
                          className={styles.image}
                          loading="lazy"
                          onError={(e) => {
                            const target = e.target as HTMLImageElement;
                            target.src = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAiIGhlaWdodD0iNDAiIHZpZXdCb3g9IjAgMCA0MCA0MCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjQwIiBoZWlnaHQ9IjQwIiBmaWxsPSIjRjVGNUY1Ii8+CjxwYXRoIGQ9Ik0yMCAyOEMyNC40MTgzIDI4IDI4IDI0LjQxODMgMjggMjBDMjggMTUuNTgxNyAyNC40MTgzIDEyIDIwIDEyQzE1LjU4MTcgMTIgMTIgMTUuNTgxNyAxMiAyMEMxMiAyNC40MTgzIDE1LjU4MTcgMjggMjAgMjhaIiBzdHJva2U9IiM5Q0EzQUYiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIi8+CjxwYXRoIGQ9Ik0yMCAxNlYyNCIgc3Ryb2tlPSIjOUNBM0FGIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPgo8cGF0aCBkPSJNMjAgMjBIMjgiIHN0cm9rZT0iIzlDQTNBRiIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz4KPC9zdmc+Cg==';
                            target.classList.add(styles.errorImage);
                          }}
                        />
                        <div className={styles.imageOverlay}>
                          <div className={styles.imageFormat}>{format.toUpperCase()}</div>
                        </div>
                      </div>
                      <div className={styles.imageInfo}>
                        <div className={styles.imageName}>{sample.name}</div>
                        <div className={styles.imageDesc}>{sample.desc}</div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            ))}
          </div>
        </div>
      </WebFListView>
    </div>
  );
};
