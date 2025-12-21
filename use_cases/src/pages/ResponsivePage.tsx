import React, { useEffect, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './ResponsivePage.module.css';

interface ViewportInfo {
  width: number;
  height: number;
  devicePixelRatio: number;
  breakpoint: string;
  orientation: string;
}

export const ResponsivePage: React.FC = () => {
  const [isFlexLayout, setIsFlexLayout] = useState(false);
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  const getBreakpoint = (width: number): string => {
    if (width >= 1200) return 'xl';
    if (width >= 992) return 'lg';
    if (width >= 768) return 'md';
    if (width >= 576) return 'sm';
    return 'xs';
  };

  const [viewportInfo, setViewportInfo] = useState<ViewportInfo>(() => {
    const width = window.innerWidth;
    const height = window.innerHeight;
    return {
      width,
      height,
      devicePixelRatio: window.devicePixelRatio,
      breakpoint: getBreakpoint(width),
      orientation: width > height ? 'landscape' : 'portrait'
    };
  });

  useEffect(() => {
    const updateViewportInfo = () => {
      const width = window.innerWidth;
      const height = window.innerHeight;
      setViewportInfo({
        width,
        height,
        devicePixelRatio: window.devicePixelRatio,
        breakpoint: getBreakpoint(width),
        orientation: width > height ? 'landscape' : 'portrait'
      });
    };

    window.addEventListener('resize', updateViewportInfo);
    return () => window.removeEventListener('resize', updateViewportInfo);
  }, []);


  const toggleLayout = () => {
    setIsFlexLayout(!isFlexLayout);
  };

  const toggleMenu = () => {
    setIsMenuOpen(!isMenuOpen);
  };


  const renderFlexItems = () => {
    const items = [
      { title: 'Header', content: 'Main navigation and branding area' },
      { title: 'Sidebar', content: 'Navigation and quick actions' },
      { title: 'Content', content: 'Primary content area with dynamic content' },
      { title: 'Footer', content: 'Secondary links and information' }
    ];
    
    return items.map((item, index) => (
      <div key={index} className={styles.flexItem}>
        <div className={styles.flexItemHeader}>{item.title}</div>
        <div className={styles.flexItemContent}>{item.content}</div>
      </div>
    ));
  };

  const renderResponsiveImages = () => {
    // Single image that changes based on current breakpoint
    const getImageForBreakpoint = () => {
      const bp = viewportInfo.breakpoint;
      if (bp === 'xs' || bp === 'sm') {
        return {
          url: 'https://picsum.photos/400/300?random=5',
          label: 'Mobile Optimized',
          description: `Current: ${viewportInfo.width}px - Using 400x300 image for faster loading on small screens`
        };
      } else if (bp === 'md') {
        return {
          url: 'https://picsum.photos/800/600?random=5',
          label: 'Tablet Optimized', 
          description: `Current: ${viewportInfo.width}px - Using 800x600 image for medium screens`
        };
      } else {
        return {
          url: 'https://picsum.photos/1200/900?random=5',
          label: 'Desktop Optimized',
          description: `Current: ${viewportInfo.width}px - Using 1200x900 image for large screens`
        };
      }
    };

    const currentImage = getImageForBreakpoint();
    
    return (
      <div className={styles.adaptiveImageContainer}>
        <div className={styles.imageContainer}>
          <img 
            src={currentImage.url}
            alt="Responsive one that changes based on screen size"
            className={styles.responsiveImage}
          />
          <div className={styles.imageLabel}>
            <div className={styles.imageSizeLabel}>{currentImage.label}</div>
            <div className={styles.imageDesc}>{currentImage.description}</div>
          </div>
        </div>
        <div className={styles.imageExplanation}>
          <strong>How it works:</strong> This image automatically switches to different resolutions based on your current screen size. 
          This saves bandwidth on mobile devices.
        </div>
      </div>
    );
  };

  const renderTypographyScale = () => {
    const textSizes = [
      { 
        name: 'Heading 1', 
        className: 'h1',
        content: `Main Title - Current width ${viewportInfo.width}px`
      },
      { 
        name: 'Heading 2', 
        className: 'h2',
        content: `Section Header - ${viewportInfo.breakpoint.toUpperCase()} breakpoint`
      },
      { 
        name: 'Heading 3', 
        className: 'h3',
        content: `Subsection Title - ${viewportInfo.orientation} orientation`
      },
      { 
        name: 'Body Large', 
        className: 'bodyLarge',
        content: `Large body text - Font size scales with rem units based on screen size`
      },
      { 
        name: 'Body', 
        className: 'body',
        content: `Regular body text - Uses CSS rem units for responsive scaling, current device pixel ratio: ${viewportInfo.devicePixelRatio}x`
      },
      { 
        name: 'Caption', 
        className: 'caption',
        content: `Small text - Caption font adapted for ${viewportInfo.breakpoint} breakpoint using CSS rem`
      }
    ];

    return textSizes.map(text => {
      return (
        <div key={text.name} className={styles.typographyItem}>
          <div className={styles.typographyLabel}>
            {text.name}
          </div>
          <div 
            className={`${styles.typographyText} ${styles[text.className]}`}
          >
            {text.content}
          </div>
        </div>
      );
    });
  };

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.componentSection}>
          <div className={styles.sectionTitle}>Responsive Design Showcase</div>
          <div className={styles.componentBlock}>
            
            {/* Viewport Information */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Viewport Information</div>
              <div className={styles.itemDesc}>Real-time viewport dimensions and breakpoint detection</div>
              <div className={styles.viewportContainer}>
                <div className={styles.viewportGrid}>
                  <div className={styles.viewportCard}>
                    <div className={styles.viewportLabel}>Width</div>
                    <div className={styles.viewportValue}>{viewportInfo.width}px</div>
                  </div>
                  <div className={styles.viewportCard}>
                    <div className={styles.viewportLabel}>Height</div>
                    <div className={styles.viewportValue}>{viewportInfo.height}px</div>
                  </div>
                  <div className={styles.viewportCard}>
                    <div className={styles.viewportLabel}>Breakpoint</div>
                    <div className={`${styles.viewportValue} ${styles.breakpoint}`}>
                      {viewportInfo.breakpoint.toUpperCase()}
                    </div>
                  </div>
                  <div className={styles.viewportCard}>
                    <div className={styles.viewportLabel}>Orientation</div>
                    <div className={styles.viewportValue}>{viewportInfo.orientation}</div>
                  </div>
                  <div className={styles.viewportCard}>
                    <div className={styles.viewportLabel}>Device Pixel Ratio</div>
                    <div className={styles.viewportValue}>{viewportInfo.devicePixelRatio}x</div>
                  </div>
                </div>
                
                <div className={styles.breakpointInfo}>
                  <div className={styles.breakpointTitle}>Breakpoint Reference</div>
                  <div className={styles.breakpointList}>
                    <span className={styles.breakpointItem}>XS: &lt; 576px</span>
                    <span className={styles.breakpointItem}>SM: ≥ 576px</span>
                    <span className={styles.breakpointItem}>MD: ≥ 768px</span>
                    <span className={styles.breakpointItem}>LG: ≥ 992px</span>
                    <span className={styles.breakpointItem}>XL: ≥ 1200px</span>
                  </div>
                </div>
              </div>
            </div>


            {/* Flexible Layout */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Flexible Layout System</div>
              <div className={styles.itemDesc}>Flexbox-based layouts that adapt to content and screen size</div>
              <div className={styles.flexContainer}>
                <div className={styles.flexControls}>
                  <button
                    className={`${styles.controlButton} ${isFlexLayout ? styles.active : ''}`}
                    onClick={toggleLayout}
                  >
                    {isFlexLayout ? 'Switch to Stack' : 'Switch to Flex'}
                  </button>
                </div>
                
                <div className={`${styles.flexLayout} ${isFlexLayout ? styles.flexRow : styles.flexColumn}`}>
                  {renderFlexItems()}
                </div>
              </div>
            </div>

            {/* Responsive Images */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Adaptive Image Loading</div>
              <div className={styles.itemDesc}>Smart image loading that serves different resolutions based on screen size to optimize performance and bandwidth usage</div>
              <div className={styles.imagesContainer}>
                <div className={styles.imagesGrid}>
                  {renderResponsiveImages()}
                </div>
              </div>
            </div>

            {/* Responsive Typography */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Responsive Typography</div>
              <div className={styles.itemDesc}>
                Font sizes scale using CSS rem units.
                <br />
                <small style={{ color: '#666', fontSize: '12px' }}>
                  Using CSS rem units with responsive root font size - a standard approach for scalable typography.
                </small>
              </div>
              <div className={styles.typographyContainer}>
                {renderTypographyScale()}
              </div>
            </div>

            {/* Media Queries Demo */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Media Queries Demonstration</div>
              <div className={styles.itemDesc}>Components that change appearance based on screen size</div>
              <div className={styles.mediaQueriesDemo}>
                <div className={styles.responsiveBox}>
                  <div className={styles.boxContent}>
                    <div className={styles.boxTitle}>Adaptive Component</div>
                    <div className={styles.boxDesc}>
                      This component changes its layout, colors, and content based on the current screen size.
                      Resize your browser window to see the changes.
                    </div>
                    <div className={styles.currentBreakpoint}>
                      Current: {viewportInfo.breakpoint.toUpperCase()}
                    </div>
                  </div>
                </div>

                <div className={styles.navigationDemo}>
                  <div className={styles.navTitle}>
                    Responsive Navigation
                    <small style={{ display: 'block', fontSize: '12px', fontWeight: 'normal', opacity: 0.7 }}>
                      Menu items hide on small screens, hamburger menu appears
                    </small>
                  </div>
                  <div className={styles.navItems}>
                    <span className={styles.navItem}>Home</span>
                    <span className={styles.navItem}>About</span>
                    <span className={styles.navItem}>Services</span>
                    <span className={styles.navItem}>Contact</span>
                    <span className={styles.navItem}>Blog</span>
                    <span className={styles.navMenu} onClick={toggleMenu}>☰</span>
                  </div>
                  {isMenuOpen && viewportInfo.width < 768 && (
                    <div className={styles.mobileMenu}>
                      <div className={styles.mobileMenuItem}>Home</div>
                      <div className={styles.mobileMenuItem}>About</div>
                      <div className={styles.mobileMenuItem}>Services</div>
                      <div className={styles.mobileMenuItem}>Contact</div>
                      <div className={styles.mobileMenuItem}>Blog</div>
                    </div>
                  )}
                  <div className={styles.navExplanation}>
                    <strong>Breakpoint behavior:</strong> Navigation items are {viewportInfo.width < 768 ? 'hidden (showing hamburger menu)' : 'visible (full navigation)'}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </WebFListView>
    </div>
  );
};
