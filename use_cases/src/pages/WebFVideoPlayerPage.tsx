import React, { useRef, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { FlutterCupertinoSlidingSegmentedControl, FlutterCupertinoSlidingSegmentedControlItem } from '@openwebf/react-cupertino-ui';
import { WebFVideoPlayer, WebFVideoPlayerElement } from '@openwebf/react-video-player';

export const WebFVideoPlayerPage: React.FC = () => {
  // Refs for different video players
  const basicPlayerRef = useRef<WebFVideoPlayerElement>(null);
  const controlledPlayerRef = useRef<WebFVideoPlayerElement>(null);
  const eventPlayerRef = useRef<WebFVideoPlayerElement>(null);
  const playlistPlayerRef = useRef<WebFVideoPlayerElement>(null);
  const customUIPlayerRef = useRef<WebFVideoPlayerElement>(null);

  // Playback rate options
  const playbackRates = [0.5, 0.75, 1, 1.25, 1.5, 2];

  // State for controlled video
  const [controlledState, setControlledState] = useState({
    isPlaying: false,
    currentTime: 0,
    duration: 0,
    volume: 1,
    muted: false,
    playbackRate: 1,
    playbackRateIndex: 2, // Default to 1x (index 2)
  });

  // State for event logging
  const [eventLogs, setEventLogs] = useState<string[]>([]);

  // State for playlist
  const [currentPlaylistIndex, setCurrentPlaylistIndex] = useState(0);
  const playlist = [
    {
      title: 'Big Buck Bunny',
      src: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      poster: 'https://via.placeholder.com/640x360/4285f4/white?text=Big+Buck+Bunny',
    },
    {
      title: 'Elephants Dream',
      src: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      poster: 'https://via.placeholder.com/640x360/ea4335/white?text=Elephants+Dream',
    },
    {
      title: 'Sintel',
      src: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
      poster: 'https://via.placeholder.com/640x360/34a853/white?text=Sintel',
    },
  ];

  // Helper to format time
  const formatTime = (seconds: number): string => {
    if (isNaN(seconds)) return '0:00';
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  // Helper to log events
  const logEvent = (eventName: string, detail?: any) => {
    const timestamp = new Date().toLocaleTimeString();
    const message = detail
      ? `[${timestamp}] ${eventName}: ${JSON.stringify(detail)}`
      : `[${timestamp}] ${eventName}`;
    setEventLogs((prev) => [message, ...prev.slice(0, 19)]);
  };

  // Handle playlist ended
  const handlePlaylistEnded = () => {
    const nextIndex = (currentPlaylistIndex + 1) % playlist.length;
    setCurrentPlaylistIndex(nextIndex);
    setTimeout(() => {
      playlistPlayerRef.current?.play();
    }, 100);
  };

  return (
    <div id="main">
      <WebFListView className="flex-1 p-0 m-0">
        <div className="p-5 bg-gray-100 min-h-screen">
          <h1 className="text-2xl font-bold text-gray-800 mb-2 text-center">
            WebF Video Player Showcase
          </h1>
          <p className="text-sm text-gray-600 text-center mb-6">
            Native Flutter video player with HTML5-compatible API
          </p>

          <div className="flex flex-col gap-8">
            {/* Use Case 1: Basic Playback */}
            <div className="bg-white rounded-xl p-6 shadow-md border border-gray-200">
              <h2 className="text-lg font-semibold text-gray-800 mb-2">1. Basic Playback</h2>
              <p className="text-sm text-gray-600 mb-4">
                Simple video player with built-in controls. Just set the src attribute and enable controls.
              </p>
              <div className="bg-gray-900 rounded-lg p-4 mb-4 overflow-x-auto">
                <code className="text-gray-300 font-mono text-sm whitespace-pre">{`<WebFVideoPlayer
  src="https://example.com/video.mp4"
  controls
  poster="https://example.com/poster.jpg"
/>`}</code>
              </div>
              <div className="bg-black rounded-lg overflow-hidden shadow-lg">
                <WebFVideoPlayer
                  ref={basicPlayerRef}
                  src="https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
                  controls
                  poster="https://via.placeholder.com/640x360/4285f4/white?text=Basic+Playback"
                  style={{ width: '100%', height: '300px' }}
                />
              </div>
            </div>

             Use Case 2: Autoplay with Muted
            <div className="bg-white rounded-xl p-6 shadow-md border border-gray-200">
              <h2 className="text-lg font-semibold text-gray-800 mb-2">2. Autoplay (Muted)</h2>
              <p className="text-sm text-gray-600 mb-4">
                Videos can autoplay when muted. This is required on most platforms for autoplay to work.
              </p>
              <div className="bg-gray-900 rounded-lg p-4 mb-4 overflow-x-auto">
                <code className="text-gray-300 font-mono text-sm whitespace-pre">{`<WebFVideoPlayer
  src="https://example.com/video.mp4"
  autoplay
  muted
  loop
  controls
/>`}</code>
              </div>
              <div className="bg-black rounded-lg overflow-hidden shadow-lg">
                <WebFVideoPlayer
                  src="https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
                  autoplay
                  muted
                  loop
                  controls
                  style={{ width: '100%', height: '300px' }}
                />
              </div>
            </div>

{/*            /!* Use Case 3: Programmatic Control *!/*/}
{/*            <div className="bg-white rounded-xl p-6 shadow-md border border-gray-200">*/}
{/*              <h2 className="text-lg font-semibold text-gray-800 mb-2">3. Programmatic Control</h2>*/}
{/*              <p className="text-sm text-gray-600 mb-4">*/}
{/*                Control video playback programmatically using JavaScript methods and properties.*/}
{/*              </p>*/}
{/*              <div className="bg-black rounded-lg overflow-hidden shadow-lg">*/}
{/*                <WebFVideoPlayer*/}
{/*                  ref={controlledPlayerRef}*/}
{/*                  src="https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"*/}
{/*                  poster="https://via.placeholder.com/640x360/ea4335/white?text=Programmatic+Control"*/}
{/*                  style={{ width: '100%', height: '300px' }}*/}
{/*                  onTimeupdate={(e) => {*/}
{/*                    setControlledState((prev) => ({*/}
{/*                      ...prev,*/}
{/*                      currentTime: e.detail?.currentTime || 0,*/}
{/*                      duration: e.detail?.duration || 0,*/}
{/*                    }));*/}
{/*                  }}*/}
{/*                  onPlay={() => setControlledState((prev) => ({ ...prev, isPlaying: true }))}*/}
{/*                  onPause={() => setControlledState((prev) => ({ ...prev, isPlaying: false }))}*/}
{/*                  onVolumechange={(e) => {*/}
{/*                    setControlledState((prev) => ({*/}
{/*                      ...prev,*/}
{/*                      volume: e.detail?.volume || 1,*/}
{/*                      muted: e.detail?.muted || false,*/}
{/*                    }));*/}
{/*                  }}*/}
{/*                />*/}
{/*              </div>*/}
{/*              <div className="bg-gradient-to-b from-gray-800 to-gray-900 p-4 rounded-b-lg">*/}
{/*                <div className="flex flex-wrap gap-3 justify-center mb-3">*/}
{/*                  <button*/}
{/*                    className="bg-white/20 hover:bg-white/30 text-white px-4 py-2 rounded-md text-sm font-medium transition-all"*/}
{/*                    onClick={() => {*/}
{/*                      if (controlledState.isPlaying) {*/}
{/*                        controlledPlayerRef.current?.pause();*/}
{/*                      } else {*/}
{/*                        controlledPlayerRef.current?.play();*/}
{/*                      }*/}
{/*                    }}*/}
{/*                  >*/}
{/*                    {controlledState.isPlaying ? 'Pause' : 'Play'}*/}
{/*                  </button>*/}
{/*                  <button*/}
{/*                    className="bg-white/20 hover:bg-white/30 text-white px-4 py-2 rounded-md text-sm font-medium transition-all"*/}
{/*                    onClick={() => {*/}
{/*                      if (controlledPlayerRef.current) {*/}
{/*                        controlledPlayerRef.current.currentTime = 0;*/}
{/*                      }*/}
{/*                    }}*/}
{/*                  >*/}
{/*                    Restart*/}
{/*                  </button>*/}
{/*                  <button*/}
{/*                    className="bg-white/20 hover:bg-white/30 text-white px-4 py-2 rounded-md text-sm font-medium transition-all"*/}
{/*                    onClick={() => {*/}
{/*                      if (controlledPlayerRef.current) {*/}
{/*                        controlledPlayerRef.current.currentTime! -= 10;*/}
{/*                      }*/}
{/*                    }}*/}
{/*                  >*/}
{/*                    -10s*/}
{/*                  </button>*/}
{/*                  <button*/}
{/*                    className="bg-white/20 hover:bg-white/30 text-white px-4 py-2 rounded-md text-sm font-medium transition-all"*/}
{/*                    onClick={() => {*/}
{/*                      if (controlledPlayerRef.current) {*/}
{/*                        controlledPlayerRef.current.currentTime! += 10;*/}
{/*                      }*/}
{/*                    }}*/}
{/*                  >*/}
{/*                    +10s*/}
{/*                  </button>*/}
{/*                </div>*/}
{/*                <div className="flex flex-wrap gap-3 justify-center items-center mb-3">*/}
{/*                  <button*/}
{/*                    className="bg-white/20 hover:bg-white/30 text-white px-4 py-2 rounded-md text-sm font-medium transition-all"*/}
{/*                    onClick={() => {*/}
{/*                      if (controlledPlayerRef.current) {*/}
{/*                        controlledPlayerRef.current.muted = !controlledPlayerRef.current.muted;*/}
{/*                      }*/}
{/*                    }}*/}
{/*                  >*/}
{/*                    {controlledState.muted ? 'Unmute' : 'Mute'}*/}
{/*                  </button>*/}
{/*                  <FlutterCupertinoSlidingSegmentedControl*/}
{/*                    currentIndex={controlledState.playbackRateIndex}*/}
{/*                    onChange={(e) => {*/}
{/*                      const index = e.detail;*/}
{/*                      const rate = playbackRates[index];*/}
{/*                      if (controlledPlayerRef.current) {*/}
{/*                        controlledPlayerRef.current.playbackRate = rate;*/}
{/*                        setControlledState((prev) => ({*/}
{/*                          ...prev,*/}
{/*                          playbackRate: rate,*/}
{/*                          playbackRateIndex: index*/}
{/*                        }));*/}
{/*                      }*/}
{/*                    }}*/}
{/*                  >*/}
{/*                    <FlutterCupertinoSlidingSegmentedControlItem title="0.5x" />*/}
{/*                    <FlutterCupertinoSlidingSegmentedControlItem title="0.75x" />*/}
{/*                    <FlutterCupertinoSlidingSegmentedControlItem title="1x" />*/}
{/*                    <FlutterCupertinoSlidingSegmentedControlItem title="1.25x" />*/}
{/*                    <FlutterCupertinoSlidingSegmentedControlItem title="1.5x" />*/}
{/*                    <FlutterCupertinoSlidingSegmentedControlItem title="2x" />*/}
{/*                  </FlutterCupertinoSlidingSegmentedControl>*/}
{/*                  <input*/}
{/*                    type="range"*/}
{/*                    min="0"*/}
{/*                    max="1"*/}
{/*                    step="0.1"*/}
{/*                    value={controlledState.volume}*/}
{/*                    onChange={(e) => {*/}
{/*                      const vol = parseFloat(e.target.value);*/}
{/*                      if (controlledPlayerRef.current) {*/}
{/*                        controlledPlayerRef.current.volume = vol;*/}
{/*                      }*/}
{/*                    }}*/}
{/*                    className="w-24"*/}
{/*                  />*/}
{/*                </div>*/}
{/*                <div className="text-center text-white/80 font-mono text-sm">*/}
{/*                  {formatTime(controlledState.currentTime)} / {formatTime(controlledState.duration)}*/}
{/*                </div>*/}
{/*              </div>*/}
{/*            </div>*/}

{/*            /!* Use Case 4: Event Handling *!/*/}
{/*            <div className="bg-white rounded-xl p-6 shadow-md border border-gray-200">*/}
{/*              <h2 className="text-lg font-semibold text-gray-800 mb-2">4. Event Handling</h2>*/}
{/*              <p className="text-sm text-gray-600 mb-4">*/}
{/*                Listen to HTML5-compatible video events for custom behavior.*/}
{/*              </p>*/}
{/*              <div className="grid grid-cols-1 md:grid-cols-2 gap-5 mb-4">*/}
{/*                <div className="min-h-[250px]">*/}
{/*                  <WebFVideoPlayer*/}
{/*                    ref={eventPlayerRef}*/}
{/*                    src="https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4"*/}
{/*                    controls*/}
{/*                    poster="https://via.placeholder.com/640x360/34a853/white?text=Event+Demo"*/}
{/*                    style={{ width: '100%', height: '250px' }}*/}
{/*                    onLoadstart={() => logEvent('loadstart')}*/}
{/*                    onLoadedmetadata={(e) => logEvent('loadedmetadata', e.detail)}*/}
{/*                    onLoadeddata={() => logEvent('loadeddata')}*/}
{/*                    onCanplay={() => logEvent('canplay')}*/}
{/*                    onCanplaythrough={() => logEvent('canplaythrough')}*/}
{/*                    onPlay={() => logEvent('play')}*/}
{/*                    onPlaying={() => logEvent('playing')}*/}
{/*                    onPause={() => logEvent('pause')}*/}
{/*                    onEnded={() => logEvent('ended')}*/}
{/*                    onWaiting={() => logEvent('waiting')}*/}
{/*                    onSeeking={() => logEvent('seeking')}*/}
{/*                    onSeeked={() => logEvent('seeked')}*/}
{/*                    onTimeupdate={(e) => {*/}
{/*                      if (Math.random() < 0.1) {*/}
{/*                        logEvent('timeupdate', e.detail);*/}
{/*                      }*/}
{/*                    }}*/}
{/*                    onVolumechange={(e) => logEvent('volumechange', e.detail)}*/}
{/*                    onRatechange={(e) => logEvent('ratechange', e.detail)}*/}
{/*                    onError={(e) => logEvent('error', e.detail)}*/}
{/*                  />*/}
{/*                </div>*/}
{/*                <div className="flex flex-col">*/}
{/*                  <div className="text-sm font-semibold text-gray-800 mb-2">Event Log</div>*/}
{/*                  <div className="bg-gray-900 rounded-lg p-3 flex-1 min-h-[200px] max-h-[200px] overflow-y-auto font-mono text-xs">*/}
{/*                    {eventLogs.length === 0 ? (*/}
{/*                      <div className="text-gray-500 text-center py-10">*/}
{/*                        Play the video to see events...*/}
{/*                      </div>*/}
{/*                    ) : (*/}
{/*                      eventLogs.map((log, i) => (*/}
{/*                        <div key={i} className="text-teal-400 py-0.5 border-b border-gray-700 last:border-0">*/}
{/*                          {log}*/}
{/*                        </div>*/}
{/*                      ))*/}
{/*                    )}*/}
{/*                  </div>*/}
{/*                  <button*/}
{/*                    className="mt-2 bg-red-500 hover:bg-red-600 text-white px-3 py-1.5 rounded text-xs"*/}
{/*                    onClick={() => setEventLogs([])}*/}
{/*                  >*/}
{/*                    Clear Log*/}
{/*                  </button>*/}
{/*                </div>*/}
{/*              </div>*/}
{/*              <div className="flex flex-col gap-2 text-xs text-gray-600">*/}
{/*                <div className="bg-gray-100 p-2 rounded">*/}
{/*                  <strong>Loading:</strong> loadstart, loadedmetadata, loadeddata, canplay, canplaythrough*/}
{/*                </div>*/}
{/*                <div className="bg-gray-100 p-2 rounded">*/}
{/*                  <strong>Playback:</strong> play, playing, pause, ended, waiting, seeking, seeked*/}
{/*                </div>*/}
{/*                <div className="bg-gray-100 p-2 rounded">*/}
{/*                  <strong>Updates:</strong> timeupdate, volumechange, ratechange, progress, error*/}
{/*                </div>*/}
{/*              </div>*/}
{/*            </div>*/}

{/*            /!* Use Case 5: Playlist *!/*/}
{/*            <div className="bg-white rounded-xl p-6 shadow-md border border-gray-200">*/}
{/*              <h2 className="text-lg font-semibold text-gray-800 mb-2">5. Playlist</h2>*/}
{/*              <p className="text-sm text-gray-600 mb-4">*/}
{/*                Create a video playlist by changing the src attribute dynamically.*/}
{/*              </p>*/}
{/*              <div className="bg-black rounded-lg overflow-hidden shadow-lg">*/}
{/*                <WebFVideoPlayer*/}
{/*                  ref={playlistPlayerRef}*/}
{/*                  src={playlist[currentPlaylistIndex].src}*/}
{/*                  poster={playlist[currentPlaylistIndex].poster}*/}
{/*                  controls*/}
{/*                  style={{ width: '100%', height: '300px' }}*/}
{/*                  onEnded={handlePlaylistEnded}*/}
{/*                />*/}
{/*              </div>*/}
{/*              <div className="mt-4 border border-gray-200 rounded-lg overflow-hidden">*/}
{/*                <div className="bg-blue-500 text-white px-4 py-3 font-semibold text-sm">*/}
{/*                  Now Playing: {playlist[currentPlaylistIndex].title}*/}
{/*                </div>*/}
{/*                <div className="max-h-[200px] overflow-y-auto">*/}
{/*                  {playlist.map((item, index) => (*/}
{/*                    <div*/}
{/*                      key={index}*/}
{/*                      className={`flex items-center px-4 py-3 cursor-pointer border-b border-gray-200 last:border-0 transition-colors ${*/}
{/*                        index === currentPlaylistIndex*/}
{/*                          ? 'bg-blue-50 hover:bg-blue-100'*/}
{/*                          : 'hover:bg-gray-50'*/}
{/*                      }`}*/}
{/*                      onClick={() => {*/}
{/*                        setCurrentPlaylistIndex(index);*/}
{/*                        setTimeout(() => {*/}
{/*                          playlistPlayerRef.current?.load();*/}
{/*                          playlistPlayerRef.current?.play();*/}
{/*                        }, 100);*/}
{/*                      }}*/}
{/*                    >*/}
{/*                      <span*/}
{/*                        className={`w-6 h-6 rounded-full flex items-center justify-center text-xs font-semibold mr-3 ${*/}
{/*                          index === currentPlaylistIndex*/}
{/*                            ? 'bg-blue-500 text-white'*/}
{/*                            : 'bg-gray-200 text-gray-600'*/}
{/*                        }`}*/}
{/*                      >*/}
{/*                        {index + 1}*/}
{/*                      </span>*/}
{/*                      <span className="flex-1 text-sm text-gray-800">{item.title}</span>*/}
{/*                      {index === currentPlaylistIndex && (*/}
{/*                        <span className="text-xs text-blue-500 font-semibold uppercase">Playing</span>*/}
{/*                      )}*/}
{/*                    </div>*/}
{/*                  ))}*/}
{/*                </div>*/}
{/*              </div>*/}
{/*            </div>*/}

{/*            /!* Use Case 6: Object Fit Options *!/*/}
            <div className="bg-white rounded-xl p-6 shadow-md border border-gray-200">
              <h2 className="text-lg font-semibold text-gray-800 mb-2">6. Object Fit Options</h2>
              <p className="text-sm text-gray-600 mb-4">
                Control how the video fits within its container using the objectFit property.
              </p>
              <div className="grid grid-cols-2 gap-4">
                {(['contain', 'cover', 'fill', 'none'] as const).map((fit) => (
                  <div key={fit} className="border border-gray-200 rounded-lg overflow-hidden">
                    <div className="bg-gray-100 px-3 py-2 text-sm font-semibold text-gray-800 text-center font-mono">
                      {fit}
                    </div>
                    <div className="bg-black h-[150px]">
                      <WebFVideoPlayer
                        src="https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4"
                        objectFit={fit}
                        muted
                        loop
                        autoplay
                        style={{ width: '100%', height: '150px' }}
                      />
                    </div>
                  </div>
                ))}
              </div>
            </div>

{/*            /!* Use Case 7: Without Controls *!/*/}
{/*            <div className="bg-white rounded-xl p-6 shadow-md border border-gray-200">*/}
{/*              <h2 className="text-lg font-semibold text-gray-800 mb-2">7. Custom UI (No Built-in Controls)</h2>*/}
{/*              <p className="text-sm text-gray-600 mb-4">*/}
{/*                Hide built-in controls to create your own custom video UI.*/}
{/*              </p>*/}
{/*              <div className="bg-gray-900 rounded-lg p-4 mb-4 overflow-x-auto">*/}
{/*                <code className="text-gray-300 font-mono text-sm whitespace-pre">{`<WebFVideoPlayer*/}
{/*  src="https://example.com/video.mp4"*/}
{/*  controls={false}*/}
{/*/>`}</code>*/}
{/*              </div>*/}
{/*              <div className="relative rounded-lg overflow-hidden">*/}
{/*                <WebFVideoPlayer*/}
{/*                  ref={customUIPlayerRef}*/}
{/*                  src="https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4"*/}
{/*                  poster="https://via.placeholder.com/640x360/fbbc04/white?text=Custom+UI"*/}
{/*                  muted*/}
{/*                  style={{ width: '100%', height: '250px' }}*/}
{/*                />*/}
{/*                <div className="absolute inset-0 flex items-center justify-center bg-black/30 hover:bg-black/40 transition-colors">*/}
{/*                  <button*/}
{/*                    className="bg-blue-500/90 hover:bg-blue-500 text-white px-8 py-4 rounded-lg text-base font-semibold transition-all hover:scale-105"*/}
{/*                    onClick={() => {*/}
{/*                      const player = customUIPlayerRef.current;*/}
{/*                      if (player) {*/}
{/*                        if (player.paused) {*/}
{/*                          player.play();*/}
{/*                        } else {*/}
{/*                          player.pause();*/}
{/*                        }*/}
{/*                      }*/}
{/*                    }}*/}
{/*                  >*/}
{/*                    Click to Play/Pause*/}
{/*                  </button>*/}
{/*                </div>*/}
{/*              </div>*/}
{/*            </div>*/}

{/*            /!* Feature Summary *!/*/}
{/*            <div className="bg-white rounded-xl p-6 shadow-md border border-gray-200">*/}
{/*              <h2 className="text-lg font-semibold text-gray-800 mb-4">Feature Summary</h2>*/}
{/*              <div className="grid grid-cols-2 md:grid-cols-3 gap-4">*/}
{/*                {[*/}
{/*                  { icon: '🎥', title: 'HTML5 API', desc: 'Familiar video element API with src, controls, autoplay, loop, muted, volume' },*/}
{/*                  { icon: '📱', title: 'Native Performance', desc: "Powered by Flutter's video_player for smooth native playback" },*/}
{/*                  { icon: '🎛️', title: 'Built-in Controls', desc: 'Play/pause, seek, volume, and progress display out of the box' },*/}
{/*                  { icon: '⚡', title: 'Full Events', desc: 'Complete HTML5 media events: play, pause, timeupdate, ended, etc.' },*/}
{/*                  { icon: '🔧', title: 'Programmatic Control', desc: 'play(), pause(), seek via currentTime, volume, playbackRate' },*/}
{/*                  { icon: '📐', title: 'Flexible Sizing', desc: 'object-fit options: contain, cover, fill, none' },*/}
{/*                ].map((feature, i) => (*/}
{/*                  <div*/}
{/*                    key={i}*/}
{/*                    className="bg-gray-50 rounded-lg p-5 text-center border border-gray-200 hover:-translate-y-0.5 hover:shadow-md transition-all"*/}
{/*                  >*/}
{/*                    <div className="text-3xl mb-3">{feature.icon}</div>*/}
{/*                    <div className="text-sm font-semibold text-gray-800 mb-2">{feature.title}</div>*/}
{/*                    <div className="text-xs text-gray-600 leading-relaxed">{feature.desc}</div>*/}
{/*                  </div>*/}
{/*                ))}*/}
{/*              </div>*/}
{/*            </div>*/}
          </div>
        </div>
      </WebFListView>
    </div>
  );
};
