import React, { useRef, useState, useCallback } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { FlutterVideoPlayer, FlutterVideoProgress, FlutterVideoPlayerElement } from '@openwebf/react-video-player';
import styles from './VideoPage.module.css';

interface VideoState {
  isPlaying: boolean;
  currentTime: number;
  duration: number;
  volume: number;
  playbackRate: number;
  paused: boolean;
  ended: boolean;
  error: string | null;
}

export const VideoPage: React.FC = () => {
  const [videoStates, setVideoStates] = useState<{[key: string]: VideoState}>({});
  
  // Test controls state
  const [testVolume, setTestVolume] = useState(1.0);
  const [testPlaybackRate, setTestPlaybackRate] = useState(1.0);
  const [testSeekTime, setTestSeekTime] = useState(0);

  const basicVideoRef = useRef<FlutterVideoPlayerElement>(null);
  const attributeVideoRef = useRef<FlutterVideoPlayerElement>(null);
  const methodVideoRef = useRef<FlutterVideoPlayerElement>(null);
  const progressVideoRef = useRef<FlutterVideoPlayerElement>(null);


  const updateVideoState = useCallback((videoId: string, updates: Partial<VideoState>) => {
    setVideoStates(prev => ({
      ...prev,
      [videoId]: { ...prev[videoId], ...updates }
    }));
  }, []);

  const handlePlay = useCallback((videoId: string) => (event: CustomEvent) => {
    updateVideoState(videoId, { isPlaying: true });
  }, [updateVideoState]);

  const handlePause = useCallback((videoId: string) => (event: CustomEvent) => {
    updateVideoState(videoId, { isPlaying: false });
  }, [updateVideoState]);

  const handleEnded = useCallback((videoId: string) => (event: CustomEvent) => {
    updateVideoState(videoId, { isPlaying: false, ended: true });
  }, [updateVideoState]);

  const handleTimeUpdate = useCallback((videoId: string) => (event: CustomEvent) => {
    const { currentTime, duration } = event.detail || {};
    if (currentTime !== undefined && duration !== undefined) {
      updateVideoState(videoId, { 
        currentTime: currentTime / 1000,
        duration: duration / 1000 
      });
    }
  }, [updateVideoState]);

  const handleLoadedMetadata = useCallback((videoId: string) => (event: CustomEvent) => {
    const { duration, videoWidth, videoHeight } = event.detail || {};
    if (duration !== undefined) {
      updateVideoState(videoId, { 
        duration: duration / 1000,
        currentTime: 0,
        isPlaying: false,
        ended: false,
        error: null
      });
    }
  }, [updateVideoState]);

  const handleError = useCallback((videoId: string) => (event: CustomEvent) => {
    const error = event.detail || 'Unknown error';
    updateVideoState(videoId, { error });
  }, [updateVideoState]);

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
          <div className={styles.sectionTitle}>Flutter Video Player Test Suite</div>
          <div className={styles.componentBlock}>
            
            {/* Basic Video Player Test */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Basic Video Player</div>
              <div className={styles.itemDesc}>Testing FlutterVideoPlayer component with basic functionality</div>
              <div className={styles.videoContainer}>
                <FlutterVideoPlayer
                  ref={basicVideoRef}
                  className={styles.videoElement}
                  src={videoSources.sample1}
                  onPlay={handlePlay('basic')}
                  onPause={handlePause('basic')}
                  onEnded={handleEnded('basic')}
                  onTimeupdate={handleTimeUpdate('basic')}
                  onLoadedmetadata={handleLoadedMetadata('basic')}
                  onError={handleError('basic')}
                />
                <div className={styles.customVideoControls}>
                  <div className={styles.controlsRow}>
                    <button 
                      className={`${styles.controlButton} ${styles.playButton}`}
                      onClick={() => {
                        if (basicVideoRef.current) {
                          if (videoStates.basic?.isPlaying) {
                            basicVideoRef.current.pause();
                          } else {
                            basicVideoRef.current.play();
                          }
                        }
                      }}
                      disabled={!videoStates.basic?.duration}
                    >
                      {videoStates.basic?.isPlaying ? '⏸️ Pause' : '▶️ Play'}
                    </button>
                    
                    <div className={styles.timeDisplay}>
                      <span className={styles.currentTime}>
                        {formatTime(videoStates.basic?.currentTime || 0)}
                      </span>
                      <span className={styles.timeSeparator}>/</span>
                      <span className={styles.totalTime}>
                        {formatTime(videoStates.basic?.duration || 0)}
                      </span>
                    </div>
                    
                    <div className={styles.statusBadges}>
                      {videoStates.basic?.paused === false && 
                        <span className={styles.badge}>▶️ Playing</span>
                      }
                      {videoStates.basic?.ended && 
                        <span className={styles.badge}>🏁 Ended</span>
                      }
                      {videoStates.basic?.error && 
                        <span className={`${styles.badge} ${styles.errorBadge}`}>❌ Error</span>
                      }
                    </div>
                  </div>
                  
                  {videoStates.basic?.error && (
                    <div className={styles.errorMessage}>
                      <strong>Error:</strong> {videoStates.basic.error}
                    </div>
                  )}
                </div>
              </div>
            </div>

            {/* Attribute Testing */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Attribute Testing</div>
              <div className={styles.itemDesc}>Testing all FlutterVideoPlayer attributes</div>
              <div className={styles.videoContainer}>
                <FlutterVideoPlayer
                  ref={attributeVideoRef}
                  className={styles.videoElement}
                  src={videoSources.sample2}
                  volume={0.8}
                  playbackRate={1.0}
                  onPlay={handlePlay('attributes')}
                  onPause={handlePause('attributes')}
                  onEnded={handleEnded('attributes')}
                  onTimeupdate={handleTimeUpdate('attributes')}
                  onLoadedmetadata={handleLoadedMetadata('attributes')}
                  onError={handleError('attributes')}
                />
                <div className={styles.attributeControls}>
                  <div className={styles.controlRow}>
                    <label>
                      Autoplay: 
                      <input 
                        type="checkbox" 
                        onChange={(e) => {
                          if (attributeVideoRef.current) {
                            if (e.target.checked) {
                              (attributeVideoRef.current as any).setAttribute('autoplay', '');
                            } else {
                              (attributeVideoRef.current as any).removeAttribute('autoplay');
                            }
                          }
                        }} 
                      />
                    </label>
                    <label>
                      Muted: 
                      <input 
                        type="checkbox" 
                        onChange={(e) => {
                          if (attributeVideoRef.current) {
                            if (e.target.checked) {
                              (attributeVideoRef.current as any).setAttribute('muted', '');
                            } else {
                              (attributeVideoRef.current as any).removeAttribute('muted');
                            }
                          }
                        }} 
                      />
                    </label>
                    <label>
                      Loop: 
                      <input 
                        type="checkbox" 
                        onChange={(e) => {
                          if (attributeVideoRef.current) {
                            if (e.target.checked) {
                              (attributeVideoRef.current as any).setAttribute('loop', '');
                            } else {
                              (attributeVideoRef.current as any).removeAttribute('loop');
                            }
                          }
                        }} 
                      />
                    </label>
                  </div>
                  <div className={styles.controlRow}>
                    <label>
                      Volume: 
                      <input 
                        type="range" 
                        min="0" 
                        max="1" 
                        step="0.1" 
                        defaultValue="0.8"
                        onChange={(e) => {
                          if (attributeVideoRef.current) {
                            (attributeVideoRef.current as any).setAttribute('volume', e.target.value);
                          }
                        }} 
                      />
                    </label>
                    <label>
                      Playback Rate: 
                      <select onChange={(e) => {
                        if (attributeVideoRef.current) {
                          (attributeVideoRef.current as any).setAttribute('playback-rate', e.target.value);
                        }
                      }}>
                        <option value="0.5">0.5x</option>
                        <option value="1.0">1.0x</option>
                        <option value="1.5">1.5x</option>
                        <option value="2.0">2.0x</option>
                      </select>
                    </label>
                  </div>
                </div>
              </div>
            </div>

            {/* Method Testing */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Method Testing</div>
              <div className={styles.itemDesc}>Testing all FlutterVideoPlayer methods</div>
              <div className={styles.videoContainer}>
                <FlutterVideoPlayer
                  ref={methodVideoRef}
                  className={styles.videoElement}
                  src={videoSources.sample3}
                  onPlay={handlePlay('methods')}
                  onPause={handlePause('methods')}
                  onEnded={handleEnded('methods')}
                  onTimeupdate={handleTimeUpdate('methods')}
                  onLoadedmetadata={handleLoadedMetadata('methods')}
                  onError={handleError('methods')}
                />
                <div className={styles.methodControls}>
                  <div className={styles.controlRow}>
                    <button onClick={() => methodVideoRef.current?.play()}>
                      Play
                    </button>
                    <button onClick={() => methodVideoRef.current?.pause()}>
                      Pause
                    </button>
                    <label>
                      Seek to: 
                      <input 
                        type="number" 
                        min="0" 
                        step="1" 
                        value={testSeekTime}
                        onChange={(e) => setTestSeekTime(Number(e.target.value))}
                      />
                      <button onClick={() => {
                        if (methodVideoRef.current) {
                          (methodVideoRef.current as any).currentTime = testSeekTime;
                        }
                      }}>
                        Seek (HTML5 Way)
                      </button>
                    </label>
                  </div>
                  <div className={styles.controlRow}>
                    <label>
                      Volume: 
                      <input 
                        type="range" 
                        min="0" 
                        max="1" 
                        step="0.1" 
                        value={testVolume}
                        onChange={(e) => {
                          const volume = Number(e.target.value);
                          setTestVolume(volume);
                          if (methodVideoRef.current) {
                            (methodVideoRef.current as any).volume = volume;
                          }
                        }}
                      />
                      {testVolume}
                    </label>
                    <label>
                      Speed: 
                      <input 
                        type="range" 
                        min="0.5" 
                        max="2" 
                        step="0.25" 
                        value={testPlaybackRate}
                        onChange={(e) => {
                          const rate = Number(e.target.value);
                          setTestPlaybackRate(rate);
                          if (methodVideoRef.current) {
                            (methodVideoRef.current as any).playbackRate = rate;
                          }
                        }}
                      />
                      {testPlaybackRate}x
                    </label>
                  </div>
                </div>
              </div>
            </div>

            {/* Progress Component Testing */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Progress Component Testing</div>
              <div className={styles.itemDesc}>Testing FlutterVideoProgress component</div>
              <div className={styles.videoContainer}>
                <FlutterVideoPlayer
                  ref={progressVideoRef}
                  className={styles.videoElement}
                  src={videoSources.sample1}
                  onPlay={handlePlay('progress')}
                  onPause={handlePause('progress')}
                  onEnded={handleEnded('progress')}
                  onTimeupdate={handleTimeUpdate('progress')}
                  onLoadedmetadata={handleLoadedMetadata('progress')}
                  onError={handleError('progress')}
                />
                <FlutterVideoProgress className={styles.progressBar} />
                <div className={styles.videoControls}>
                  <button onClick={() => {
                    if (progressVideoRef.current) {
                      if (videoStates.progress?.isPlaying) {
                        progressVideoRef.current.pause();
                      } else {
                        progressVideoRef.current.play();
                      }
                    }
                  }}>
                    {videoStates.progress?.isPlaying ? 'Pause' : 'Play'}
                  </button>
                  <div className={styles.timeInfo}>
                    {formatTime(videoStates.progress?.currentTime || 0)} / {formatTime(videoStates.progress?.duration || 0)}
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