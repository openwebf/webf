<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, reactive, ref } from 'vue';
import styles from './ResponsivePage.module.css';

type ViewportInfo = {
  width: number;
  height: number;
  devicePixelRatio: number;
  breakpoint: string;
  orientation: string;
};

const isFlexLayout = ref(false);
const isMenuOpen = ref(false);

function getBreakpoint(width: number): string {
  if (width >= 1200) return 'xl';
  if (width >= 992) return 'lg';
  if (width >= 768) return 'md';
  if (width >= 576) return 'sm';
  return 'xs';
}

const viewportInfo = reactive<ViewportInfo>({
  width: window.innerWidth,
  height: window.innerHeight,
  devicePixelRatio: window.devicePixelRatio,
  breakpoint: getBreakpoint(window.innerWidth),
  orientation: window.innerWidth > window.innerHeight ? 'landscape' : 'portrait',
});

function updateViewportInfo() {
  const width = window.innerWidth;
  const height = window.innerHeight;
  viewportInfo.width = width;
  viewportInfo.height = height;
  viewportInfo.devicePixelRatio = window.devicePixelRatio;
  viewportInfo.breakpoint = getBreakpoint(width);
  viewportInfo.orientation = width > height ? 'landscape' : 'portrait';
}

onMounted(() => {
  window.addEventListener('resize', updateViewportInfo);
});

onBeforeUnmount(() => {
  window.removeEventListener('resize', updateViewportInfo);
});

function toggleLayout() {
  isFlexLayout.value = !isFlexLayout.value;
}

function toggleMenu() {
  isMenuOpen.value = !isMenuOpen.value;
}

const flexItems = [
  { title: 'Header', content: 'Main navigation and branding area' },
  { title: 'Sidebar', content: 'Navigation and quick actions' },
  { title: 'Content', content: 'Primary content area with dynamic content' },
  { title: 'Footer', content: 'Secondary links and information' },
];

const currentImage = computed(() => {
  const bp = viewportInfo.breakpoint;
  if (bp === 'xs' || bp === 'sm') {
    return {
      url: 'https://picsum.photos/400/300?random=5',
      label: 'Mobile Optimized',
      description: `Current: ${viewportInfo.width}px - Using 400x300 image for faster loading on small screens`,
    };
  }
  if (bp === 'md') {
    return {
      url: 'https://picsum.photos/800/600?random=5',
      label: 'Tablet Optimized',
      description: `Current: ${viewportInfo.width}px - Using 800x600 image for medium screens`,
    };
  }
  return {
    url: 'https://picsum.photos/1200/900?random=5',
    label: 'Desktop Optimized',
    description: `Current: ${viewportInfo.width}px - Using 1200x900 image for large screens`,
  };
});

const typographyScale = computed(() => [
  { name: 'Heading 1', className: 'h1', content: `Main Title - Current width ${viewportInfo.width}px` },
  { name: 'Heading 2', className: 'h2', content: `Section Header - ${viewportInfo.breakpoint.toUpperCase()} breakpoint` },
  { name: 'Heading 3', className: 'h3', content: `Subsection Title - ${viewportInfo.orientation} orientation` },
  { name: 'Body Large', className: 'bodyLarge', content: 'Large body text - Font size scales with rem units based on screen size' },
  {
    name: 'Body',
    className: 'body',
    content: `Regular body text - Uses CSS rem units for responsive scaling, current device pixel ratio: ${viewportInfo.devicePixelRatio}x`,
  },
  { name: 'Caption', className: 'caption', content: `Small text - Caption font adapted for ${viewportInfo.breakpoint} breakpoint using CSS rem` },
]);

const navBreakpointExplanation = computed(
  () => `Navigation items are ${viewportInfo.width < 768 ? 'hidden (showing hamburger menu)' : 'visible (full navigation)'}`,
);
</script>

<template>
  <div id="main">
    <webf-list-view :class="styles.list">
      <div :class="styles.componentSection">
        <div :class="styles.sectionTitle">Responsive Design Showcase</div>
        <div :class="styles.componentBlock">
          <div :class="styles.componentItem">
            <div :class="styles.itemLabel">Viewport Information</div>
            <div :class="styles.itemDesc">Real-time viewport dimensions and breakpoint detection</div>
            <div :class="styles.viewportContainer">
              <div :class="styles.viewportGrid">
                <div :class="styles.viewportCard">
                  <div :class="styles.viewportLabel">Width</div>
                  <div :class="styles.viewportValue">{{ viewportInfo.width }}px</div>
                </div>
                <div :class="styles.viewportCard">
                  <div :class="styles.viewportLabel">Height</div>
                  <div :class="styles.viewportValue">{{ viewportInfo.height }}px</div>
                </div>
                <div :class="styles.viewportCard">
                  <div :class="styles.viewportLabel">Breakpoint</div>
                  <div :class="[styles.viewportValue, styles.breakpoint]">{{ viewportInfo.breakpoint.toUpperCase() }}</div>
                </div>
                <div :class="styles.viewportCard">
                  <div :class="styles.viewportLabel">Orientation</div>
                  <div :class="styles.viewportValue">{{ viewportInfo.orientation }}</div>
                </div>
                <div :class="styles.viewportCard">
                  <div :class="styles.viewportLabel">Device Pixel Ratio</div>
                  <div :class="styles.viewportValue">{{ viewportInfo.devicePixelRatio }}x</div>
                </div>
              </div>

              <div :class="styles.breakpointInfo">
                <div :class="styles.breakpointTitle">Breakpoint Reference</div>
                <div :class="styles.breakpointList">
                  <span :class="styles.breakpointItem">XS: &lt; 576px</span>
                  <span :class="styles.breakpointItem">SM: ≥ 576px</span>
                  <span :class="styles.breakpointItem">MD: ≥ 768px</span>
                  <span :class="styles.breakpointItem">LG: ≥ 992px</span>
                  <span :class="styles.breakpointItem">XL: ≥ 1200px</span>
                </div>
              </div>
            </div>
          </div>

          <div :class="styles.componentItem">
            <div :class="styles.itemLabel">Flexible Layout System</div>
            <div :class="styles.itemDesc">Flexbox-based layouts that adapt to content and screen size</div>
            <div :class="styles.flexContainer">
              <div :class="styles.flexControls">
                <button :class="[styles.controlButton, isFlexLayout ? styles.active : '']" @click="toggleLayout">
                  {{ isFlexLayout ? 'Switch to Stack' : 'Switch to Flex' }}
                </button>
              </div>

              <div :class="[styles.flexLayout, isFlexLayout ? styles.flexRow : styles.flexColumn]">
                <div v-for="(item, index) in flexItems" :key="index" :class="styles.flexItem">
                  <div :class="styles.flexItemHeader">{{ item.title }}</div>
                  <div :class="styles.flexItemContent">{{ item.content }}</div>
                </div>
              </div>
            </div>
          </div>

          <div :class="styles.componentItem">
            <div :class="styles.itemLabel">Adaptive Image Loading</div>
            <div :class="styles.itemDesc">
              Smart image loading that serves different resolutions based on screen size to optimize performance and bandwidth usage
            </div>
            <div :class="styles.imagesContainer">
              <div :class="styles.imagesGrid">
                <div :class="styles.adaptiveImageContainer">
                  <div :class="styles.imageContainer">
                    <img :src="currentImage.url" alt="Responsive one that changes based on screen size" :class="styles.responsiveImage" />
                    <div :class="styles.imageLabel">
                      <div :class="styles.imageSizeLabel">{{ currentImage.label }}</div>
                      <div :class="styles.imageDesc">{{ currentImage.description }}</div>
                    </div>
                  </div>
                  <div :class="styles.imageExplanation">
                    <strong>How it works:</strong> This image automatically switches to different resolutions based on your current screen size. This saves bandwidth on mobile
                    devices.
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div :class="styles.componentItem">
            <div :class="styles.itemLabel">Responsive Typography</div>
            <div :class="styles.itemDesc">
              Font sizes scale using CSS rem units.
              <br />
              <small style="color: #666; font-size: 12px">Using CSS rem units with responsive root font size - a standard approach for scalable typography.</small>
            </div>
            <div :class="styles.typographyContainer">
              <div v-for="item in typographyScale" :key="item.name" :class="styles.typographyItem">
                <div :class="styles.typographyLabel">{{ item.name }}</div>
                <div :class="[styles.typographyText, styles[item.className]]">{{ item.content }}</div>
              </div>
            </div>
          </div>

          <div :class="styles.componentItem">
            <div :class="styles.itemLabel">Media Queries Demonstration</div>
            <div :class="styles.itemDesc">Components that change appearance based on screen size</div>
            <div :class="styles.mediaQueriesDemo">
              <div :class="styles.responsiveBox">
                <div :class="styles.boxContent">
                  <div :class="styles.boxTitle">Adaptive Component</div>
                  <div :class="styles.boxDesc">
                    This component changes its layout, colors, and content based on the current screen size. Resize your browser window to see the changes.
                  </div>
                  <div :class="styles.currentBreakpoint">Current: {{ viewportInfo.breakpoint.toUpperCase() }}</div>
                </div>
              </div>

              <div :class="styles.navigationDemo">
                <div :class="styles.navTitle">
                  Responsive Navigation
                  <small style="display: block; font-size: 12px; font-weight: normal; opacity: 0.7">Menu items hide on small screens, hamburger menu appears</small>
                </div>
                <div :class="styles.navItems">
                  <span :class="styles.navItem">Home</span>
                  <span :class="styles.navItem">About</span>
                  <span :class="styles.navItem">Services</span>
                  <span :class="styles.navItem">Contact</span>
                  <span :class="styles.navItem">Blog</span>
                  <span :class="styles.navMenu" @click="toggleMenu">☰</span>
                </div>
                <div v-if="isMenuOpen && viewportInfo.width < 768" :class="styles.mobileMenu">
                  <div :class="styles.mobileMenuItem">Home</div>
                  <div :class="styles.mobileMenuItem">About</div>
                  <div :class="styles.mobileMenuItem">Services</div>
                  <div :class="styles.mobileMenuItem">Contact</div>
                  <div :class="styles.mobileMenuItem">Blog</div>
                </div>
                <div :class="styles.navExplanation"><strong>Breakpoint behavior:</strong> {{ navBreakpointExplanation }}</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
