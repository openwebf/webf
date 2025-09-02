import React, { useRef, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './VideoPage.module.css';

export const VideoPage: React.FC = () => {
  const [videoStates, setVideoStates] = useState<{[key: string]: {isPlaying: boolean, currentTime: number, duration: number}}>({});
  
  const basicVideoRef = useRef<HTMLVideoElement | null>(null);
  const customVideoRef = useRef<HTMLVideoElement | null>(null);

  const updateVideoState = (videoId: string, updates: Partial<{isPlaying: boolean, currentTime: number, duration: number}>) => {
    setVideoStates(prev => ({
      ...prev,
      [videoId]: { ...prev[videoId], ...updates }
    }));
  };

  const togglePlay = (videoRef: React.RefObject<HTMLVideoElement | null>, videoId: string) => {
    if (videoRef.current) {
      const video = videoRef.current;
      if (video.paused) {
        video.play();
        updateVideoState(videoId, { isPlaying: true });
      } else {
        video.pause();
        updateVideoState(videoId, { isPlaying: false });
      }
    }
  };

  const handleTimeUpdate = (videoId: string, event: React.SyntheticEvent<HTMLVideoElement>) => {
    const video = event.currentTarget;
    updateVideoState(videoId, { 
      currentTime: video.currentTime, 
      duration: video.duration || 0 
    });
  };

  const handleLoadedMetadata = (videoId: string, event: React.SyntheticEvent<HTMLVideoElement>) => {
    const video = event.currentTarget;
    updateVideoState(videoId, { 
      duration: video.duration,
      currentTime: 0,
      isPlaying: false
    });
  };

  const seekTo = (videoRef: React.RefObject<HTMLVideoElement | null>, time: number) => {
    if (videoRef.current) {
      videoRef.current.currentTime = time;
    }
  };

  const formatTime = (time: number) => {
    if (isNaN(time)) return '0:00';
    const minutes = Math.floor(time / 60);
    const seconds = Math.floor(time % 60);
    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
  };

  const videoSources = {
    sample1: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    sample2: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    sample3: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4'
  };

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.componentSection}>
          <div className={styles.sectionTitle}>Video Player Showcase</div>
          <div className={styles.componentBlock}>
            
            {/* Basic Video Player */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Basic Video Player</div>
              <div className={styles.itemDesc}>Standard HTML5 video with basic controls</div>
              <div className={styles.videoContainer}>
                <video
                  ref={basicVideoRef}
                  className={styles.videoElement}
                  onTimeUpdate={(e) => handleTimeUpdate('basic', e)}
                  onLoadedMetadata={(e) => handleLoadedMetadata('basic', e)}
                  poster="https://via.placeholder.com/640x360/4285f4/white?text=Video+Poster"
                >
                  <source src={videoSources.sample1} type="video/mp4" />
                  Your browser does not support the video tag.
                </video>
                <div className={styles.videoControls}>
                  <button 
                    className={styles.playButton}
                    onClick={() => togglePlay(basicVideoRef, 'basic')}
                  >
                    {videoStates.basic?.isPlaying ? '⏸️' : '▶️'}
                  </button>
                  <div className={styles.timeInfo}>
                    {formatTime(videoStates.basic?.currentTime || 0)} / {formatTime(videoStates.basic?.duration || 0)}
                  </div>
                  <input
                    type="range"
                    className={styles.progressBar}
                    min="0"
                    max={videoStates.basic?.duration || 100}
                    value={videoStates.basic?.currentTime || 0}
                    onChange={(e) => seekTo(basicVideoRef, parseFloat(e.target.value))}
                  />
                </div>
              </div>
            </div>

            {/* Custom Styled Video Player */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Custom Styled Video Player</div>
              <div className={styles.itemDesc}>Video player with custom controls and styling</div>
              <div className={styles.videoContainer}>
                <video
                  ref={customVideoRef}
                  className={styles.videoElement}
                  onTimeUpdate={(e) => handleTimeUpdate('custom', e)}
                  onLoadedMetadata={(e) => handleLoadedMetadata('custom', e)}
                  poster="https://via.placeholder.com/640x360/ea4335/white?text=Custom+Video"
                >
                  <source src={videoSources.sample2} type="video/mp4" />
                  Your browser does not support the video tag.
                </video>
                <div className={styles.customControls}>
                  <div className={styles.controlsRow}>
                    <button 
                      className={`${styles.controlButton} ${styles.playButtonLarge}`}
                      onClick={() => togglePlay(customVideoRef, 'custom')}
                    >
                      {videoStates.custom?.isPlaying ? 'Pause' : 'Play'}
                    </button>
                    <button 
                      className={styles.controlButton}
                      onClick={() => seekTo(customVideoRef, 0)}
                    >
                      Restart
                    </button>
                    <button 
                      className={styles.controlButton}
                      onClick={() => seekTo(customVideoRef, (videoStates.custom?.currentTime || 0) - 10)}
                    >
                      -10s
                    </button>
                    <button 
                      className={styles.controlButton}
                      onClick={() => seekTo(customVideoRef, (videoStates.custom?.currentTime || 0) + 10)}
                    >
                      +10s
                    </button>
                  </div>
                  <div className={styles.progressContainer}>
                    <span className={styles.timeLabel}>
                      {formatTime(videoStates.custom?.currentTime || 0)}
                    </span>
                    <div className={styles.progressWrapper}>
                      <input
                        type="range"
                        className={styles.customProgressBar}
                        min="0"
                        max={videoStates.custom?.duration || 100}
                        value={videoStates.custom?.currentTime || 0}
                        onChange={(e) => seekTo(customVideoRef, parseFloat(e.target.value))}
                      />
                    </div>
                    <span className={styles.timeLabel}>
                      {formatTime(videoStates.custom?.duration || 0)}
                    </span>
                  </div>
                </div>
              </div>
            </div>

            {/* Multiple Video Sources */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Multiple Video Examples</div>
              <div className={styles.itemDesc}>Different video content with various aspect ratios and formats</div>
              <div className={styles.videoGrid}>
                <div className={styles.videoGridItem}>
                  <video
                    className={styles.gridVideoElement}
                    controls
                    poster="https://via.placeholder.com/400x225/34a853/white?text=Sample+1"
                  >
                    <source src={videoSources.sample1} type="video/mp4" />
                  </video>
                  <div className={styles.videoInfo}>
                    <div className={styles.videoTitle}>Big Buck Bunny</div>
                    <div className={styles.videoDesc}>Open source animated short film</div>
                  </div>
                </div>
                
                <div className={styles.videoGridItem}>
                  <video
                    className={styles.gridVideoElement}
                    controls
                    poster="https://via.placeholder.com/400x225/fbbc04/white?text=Sample+2"
                  >
                    <source src={videoSources.sample2} type="video/mp4" />
                  </video>
                  <div className={styles.videoInfo}>
                    <div className={styles.videoTitle}>Elephants Dream</div>
                    <div className={styles.videoDesc}>Fantasy adventure animation</div>
                  </div>
                </div>
                
                <div className={styles.videoGridItem}>
                  <video
                    className={styles.gridVideoElement}
                    controls
                    poster="https://via.placeholder.com/400x225/ea4335/white?text=Sample+3"
                  >
                    <source src={videoSources.sample3} type="video/mp4" />
                  </video>
                  <div className={styles.videoInfo}>
                    <div className={styles.videoTitle}>Sintel</div>
                    <div className={styles.videoDesc}>Open movie project by Blender</div>
                  </div>
                </div>
              </div>
            </div>

            {/* Video Features */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Video Player Features</div>
              <div className={styles.itemDesc}>Supported video capabilities and formats</div>
              <div className={styles.featuresGrid}>
                <div className={styles.featureCard}>
                  <div className={styles.featureIcon}>🎥</div>
                  <div className={styles.featureTitle}>Format Support</div>
                  <div className={styles.featureDesc}>MP4, WebM, OGV and other standard formats</div>
                </div>
                
                <div className={styles.featureCard}>
                  <div className={styles.featureIcon}>⏯️</div>
                  <div className={styles.featureTitle}>Playback Controls</div>
                  <div className={styles.featureDesc}>Play, pause, seek, and time display</div>
                </div>
                
                <div className={styles.featureCard}>
                  <div className={styles.featureIcon}>📱</div>
                  <div className={styles.featureTitle}>Responsive Design</div>
                  <div className={styles.featureDesc}>Adapts to different screen sizes</div>
                </div>
                
                <div className={styles.featureCard}>
                  <div className={styles.featureIcon}>🖼️</div>
                  <div className={styles.featureTitle}>Poster Images</div>
                  <div className={styles.featureDesc}>Custom thumbnail images before playback</div>
                </div>
                
                <div className={styles.featureCard}>
                  <div className={styles.featureIcon}>⚙️</div>
                  <div className={styles.featureTitle}>Custom Controls</div>
                  <div className={styles.featureDesc}>Build your own player interface</div>
                </div>
                
                <div className={styles.featureCard}>
                  <div className={styles.featureIcon}>🔧</div>
                  <div className={styles.featureTitle}>Event Handling</div>
                  <div className={styles.featureDesc}>React to play, pause, and time events</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </WebFListView>
    </div>
  );
};