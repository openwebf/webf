import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './BasicFormElementsPage.module.css';

export const BasicFormElementsPage: React.FC = () => {
  const [textValue, setTextValue] = useState('');
  const [radioValue, setRadioValue] = useState('red');
  const [checkboxValues, setCheckboxValues] = useState<string[]>([]);

  const handleTextChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    console.log('handleTextChange', e.target.value);
    setTextValue(e.target.value);
  };

  const handleRadioChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    console.log('handleRadioChange', e.target.value);
    setRadioValue(e.target.value);
  };

  const handleCheckboxChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    if (e.target.checked) {
      setCheckboxValues([...checkboxValues, value]);
    } else {
      setCheckboxValues(checkboxValues.filter(item => item !== value));
    }
  };

  const resetForm = () => {
    setTextValue('');
    setRadioValue('');
    setCheckboxValues([]);
  };

  return (
    <div className={styles.pageContainer}>
      <WebFListView>
        <h1 className={styles.pageTitle}>Basic Form Elements</h1>
        <p className={styles.pageDescription}>
          Basic examples of HTML form elements: text input, radio buttons, and checkboxes.
        </p>

        <div className={styles.formContainer}>
        {/* Text Input Section */}
        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>Text Input</h2>
          <div className={styles.inputGroup}>
            <label className={styles.label} htmlFor="textInput">Name:</label>
            <input
              id="textInput"
              type="text"
              value={textValue}
              onChange={handleTextChange}
              placeholder="Enter your name"
              className={styles.textInput}
            />
            <div className={styles.inputValue}>Current value: "{textValue}"</div>
          </div>
        </div>

        {/* Radio Button Section */}
        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>Radio Buttons</h2>
          <div className={styles.inputGroup}>
            <div className={styles.label}>Choose your favorite color:</div>
            <div className={styles.radioGroup}>
              <label className={styles.radioLabel}>
                <input
                  type="radio"
                  name="color"
                  value="red"
                  checked={radioValue === 'red'}
                  onChange={handleRadioChange}
                  className={styles.radioInput}
                />
                Red
              </label>
              <label className={styles.radioLabel}>
                <input
                  type="radio"
                  name="color"
                  value="blue"
                  checked={radioValue === 'blue'}
                  onChange={handleRadioChange}
                  className={styles.radioInput}
                />
                Blue
              </label>
              <label className={styles.radioLabel}>
                <input
                  type="radio"
                  name="color"
                  value="green"
                  checked={radioValue === 'green'}
                  onChange={handleRadioChange}
                  className={styles.radioInput}
                />
                Green
              </label>
            </div>
            <div className={styles.inputValue}>Selected: "{radioValue}"</div>
          </div>
        </div>

        {/* Checkbox Section */}
        <div className={styles.section}>
          <h2 className={styles.sectionTitle}>Checkboxes</h2>
          <div className={styles.inputGroup}>
            <div className={styles.label}>Select your hobbies:</div>
            <div className={styles.checkboxGroup}>
              <label className={styles.checkboxLabel}>
                <input
                  type="checkbox"
                  value="reading"
                  checked={checkboxValues.includes('reading')}
                  onChange={handleCheckboxChange}
                  className={styles.checkboxInput}
                />
                Reading
              </label>
              <label className={styles.checkboxLabel}>
                <input
                  type="checkbox"
                  value="sports"
                  checked={checkboxValues.includes('sports')}
                  onChange={handleCheckboxChange}
                  className={styles.checkboxInput}
                />
                Sports
              </label>
              <label className={styles.checkboxLabel}>
                <input
                  type="checkbox"
                  value="music"
                  checked={checkboxValues.includes('music')}
                  onChange={handleCheckboxChange}
                  className={styles.checkboxInput}
                />
                Music
              </label>
              <label className={styles.checkboxLabel}>
                <input
                  type="checkbox"
                  value="travel"
                  checked={checkboxValues.includes('travel')}
                  onChange={handleCheckboxChange}
                  className={styles.checkboxInput}
                />
                Travel
              </label>
            </div>
            <div className={styles.inputValue}>
              Selected: [{checkboxValues.join(', ')}]
            </div>
          </div>
        </div>

        {/* Reset Button */}
        <div className={styles.actions}>
          <button onClick={resetForm} className={styles.resetButton}>
            Reset All
          </button>
        </div>

        {/* Summary Section */}
        <div className={styles.summary}>
          <h2 className={styles.sectionTitle}>Form Summary</h2>
          <div className={styles.summaryContent}>
            <div><strong>Name:</strong> {textValue || 'Not entered'}</div>
            <div><strong>Favorite Color:</strong> {radioValue || 'Not selected'}</div>
            <div><strong>Hobbies:</strong> {checkboxValues.length > 0 ? checkboxValues.join(', ') : 'None selected'}</div>
          </div>
        </div>
        </div>
      </WebFListView>
    </div>
  );
};