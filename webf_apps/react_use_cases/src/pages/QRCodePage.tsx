import React, { useState, useRef } from 'react';
import { QRCodeCanvas } from 'qrcode.react';
import { 
  FlutterCupertinoButton, FlutterCupertinoTextarea, FlutterCupertinoModalPopupElement, 
  FlutterCupertinoModalPopup, FlutterCupertinoPicker, FlutterCupertinoPickerItem,
} from '@openwebf/react-cupertino-ui';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './QRCodePage.module.css';


export const QRCodePage: React.FC = () => {
  const [textValue, setTextValue] = useState('https://openwebf.com');
  const [customText, setCustomText] = useState('');
  const [bgColor, setBgColor] = useState('#FFFFFF');
  const [fgColor, setFgColor] = useState('#000000');
  const [errorLevel, setErrorLevel] = useState<'L' | 'M' | 'Q' | 'H'>('M');

  const fgColorPickerRef = useRef<FlutterCupertinoModalPopupElement>(null);
  const bgColorPickerRef = useRef<FlutterCupertinoModalPopupElement>(null);
  const errorLevelPickerRef = useRef<FlutterCupertinoModalPopupElement>(null);

  const colorPresets = [
    { name: 'Black', value: '#000000' },
    { name: 'White', value: '#FFFFFF' },
    { name: 'Blue', value: '#007AFF' },
    { name: 'Green', value: '#34C759' },
    { name: 'Red', value: '#FF3B30' },
    { name: 'Orange', value: '#FF9500' },
    { name: 'Purple', value: '#AF52DE' },
    { name: 'Pink', value: '#FF2D55' }
  ];
  
  const errorLevelOptions = [
    { label: 'Low (7% correction)', value: 'L' },
    { label: 'Medium (15% correction)', value: 'M' },
    { label: 'Quartile (25% correction)', value: 'Q' },
    { label: 'High (30% correction)', value: 'H' }
  ];
  
  const qrExamples = [
    {
      title: 'URL QR Code',
      value: 'https://github.com/openwebf/webf',
      description: 'Scan to visit WebF GitHub repository'
    },
    {
      title: 'WiFi Configuration',
      value: 'WIFI:T:WPA;S:MyNetwork;P:MyPassword;H:false;;',
      description: 'WiFi connection QR code (Example format)'
    },
    {
      title: 'Email Contact',
      value: 'mailto:contact@example.com?subject=Hello&body=I would like to get in touch',
      description: 'Scan to send an email'
    },
    {
      title: 'Phone Number',
      value: 'tel:+1234567890',
      description: 'Scan to call this number'
    },
    {
      title: 'SMS Message',
      value: 'sms:+1234567890?body=Hello from WebF QR Code',
      description: 'Scan to send SMS'
    },
    {
      title: 'Geo Location',
      value: 'geo:37.7749,-122.4194',
      description: 'San Francisco coordinates'
    },
    {
      title: 'Plain Text',
      value: 'WebF - Build Flutter apps with web technologies!',
      description: 'Simple text message'
    },
    {
      title: 'JSON Data',
      value: JSON.stringify({ app: 'WebF', version: '0.22.0', features: ['React', 'Flutter', 'Web'] }, null, 2),
      description: 'Structured JSON data'
    }
  ];

  const handleExampleClick = (value: string) => {
    setTextValue(value);
  };

  const handleCustomGenerate = () => {
    if (customText.trim()) {
      setTextValue(customText);
    }
  };

  const handleTextareaChange = (event: any) => {
    const value = event.detail || '';
    setCustomText(value);
  };

  const handleFgColorPickerChange = (event: any) => {
    const index = parseInt(event.detail);
    if (colorPresets[index]) {
      setFgColor(colorPresets[index].value);
    }
  };

  const handleBgColorPickerChange = (event: any) => {
    const index = parseInt(event.detail);
    if (colorPresets[index]) {
      setBgColor(colorPresets[index].value);
    }
  };

  const handleErrorLevelPickerChange = (event: any) => {
    const index = parseInt(event.detail);
    if (errorLevelOptions[index]) {
      setErrorLevel(errorLevelOptions[index].value as 'L' | 'M' | 'Q' | 'H');
    }
  };

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.componentSection}>
          <div className={styles.sectionTitle}>QR Code Generator</div>
          
          {/* Current QR Code Display */}
          <div className={styles.qrCodeDisplay}>
            <div className={styles.qrCodeContainer} id="qr-code-canvas">
              <QRCodeCanvas
                value={textValue}
                size={256}
                bgColor={bgColor}
                fgColor={fgColor}
                level={errorLevel}
                includeMargin={false}
              />
            </div>
            <div className={styles.qrInfo}>
              <h3>Current QR Code Content:</h3>
              <div className={styles.contentDisplay}>
                <code>{textValue}</code>
              </div>
            </div>
          </div>

          {/* QR Code Settings */}
          <div className={styles.componentBlock}>
            <h3>QR Code Settings</h3>
            <div className={styles.settingsGrid}>
              <div className={styles.settingItem}>
                <label>Foreground Color:</label>
                <FlutterCupertinoButton
                  variant="tinted"
                  size="small"
                  onClick={() => {
                    fgColorPickerRef.current?.show()
                  }}
                  className={styles.colorButton}
                >
                  <span className={styles.colorPreview} style={{backgroundColor: fgColor}}></span>
                  {colorPresets.find(c => c.value === fgColor)?.name || fgColor}
                </FlutterCupertinoButton>
              </div>

              <div className={styles.settingItem}>
                <label>Background Color:</label>
                <FlutterCupertinoButton
                  variant="tinted"
                  size="small"
                  onClick={() => {
                    bgColorPickerRef.current?.show()
                  }}
                  className={styles.colorButton}
                >
                  <span className={styles.colorPreview} style={{backgroundColor: bgColor}}></span>
                  {colorPresets.find(c => c.value === bgColor)?.name || bgColor}
                </FlutterCupertinoButton>
              </div>

              <div className={styles.settingItem}>
                <label>Error Correction Level:</label>
                <FlutterCupertinoButton
                  variant="filled"
                  size="small"
                  onClick={() => {
                    errorLevelPickerRef.current?.show()
                  }}
                  className={styles.selectButton}
                >
                  {errorLevel === 'L' && 'Low (7%)'}
                  {errorLevel === 'M' && 'Medium (15%)'}
                  {errorLevel === 'Q' && 'Quartile (25%)'}
                  {errorLevel === 'H' && 'High (30%)'}
                </FlutterCupertinoButton>
              </div>
            </div>
          </div>

          {/* Custom QR Code Generator */}
          <div className={styles.componentBlock}>
            <h3>Custom QR Code Generator</h3>
            <div className={styles.customGenerator}>
              <FlutterCupertinoTextarea
                placeholder="Enter text, URL, or any data to encode..."
                val={customText}
                onInput={handleTextareaChange}
                className={styles.textArea}
                rows={4}
              />
              <FlutterCupertinoButton 
                variant="filled"
                onClick={handleCustomGenerate} 
                className={styles.generateButton}
              >
                Generate QR Code
              </FlutterCupertinoButton>
            </div>
          </div>

          {/* QR Code Examples */}
          <div className={styles.componentBlock}>
            <h3>QR Code Examples</h3>
            <div className={styles.examplesGrid}>
              {qrExamples.map((example, index) => (
                <div
                  key={index}
                  className={styles.exampleCard}
                  onClick={() => handleExampleClick(example.value)}
                >
                  <div className={styles.miniQrCode}>
                    <QRCodeCanvas
                      value={example.value}
                      size={80}
                      bgColor="#FFFFFF"
                      fgColor="#000000"
                      level="M"
                      includeMargin={false}
                    />
                  </div>
                  <div className={styles.exampleContent}>
                    <h4>{example.title}</h4>
                    <p>{example.description}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </WebFListView>
      
      {/* Modal Popup for Foreground Color Selection */}
      <FlutterCupertinoModalPopup
        ref={fgColorPickerRef}
        onClose={() => {
          fgColorPickerRef.current?.hide();
        }}
      >
        <FlutterCupertinoPicker
          onChange={handleFgColorPickerChange}
        >
          {colorPresets.map((preset, index) => (
            <FlutterCupertinoPickerItem
              key={preset.value}
              label={`${preset.name} (${preset.value})`}
              val={index.toString()}
            />
          ))}
        </FlutterCupertinoPicker>
      </FlutterCupertinoModalPopup>
      
      {/* Modal Popup for Background Color Selection */}
      <FlutterCupertinoModalPopup
        ref={bgColorPickerRef}
        onClose={() => {
          bgColorPickerRef.current?.hide();
        }}
      >
        <FlutterCupertinoPicker
          onChange={handleBgColorPickerChange}
        >
          {colorPresets.map((preset, index) => (
            <FlutterCupertinoPickerItem
              key={preset.value}
              label={`${preset.name} (${preset.value})`}
              val={index.toString()}
            />
          ))}
        </FlutterCupertinoPicker>
      </FlutterCupertinoModalPopup>
      
      {/* Modal Popup for Error Level Selection */}
      <FlutterCupertinoModalPopup
        ref={errorLevelPickerRef}
        onClose={() => {  
          errorLevelPickerRef.current?.hide()
        }}
      >
        <FlutterCupertinoPicker
          onChange={handleErrorLevelPickerChange}
        >
          {errorLevelOptions.map((option, index) => (
            <FlutterCupertinoPickerItem
              key={option.value}
              label={option.label}
              val={index.toString()}
            />
          ))}
        </FlutterCupertinoPicker>
      </FlutterCupertinoModalPopup>
    </div>
  );
};