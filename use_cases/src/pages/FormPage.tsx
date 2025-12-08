import React, { useState, useRef, useEffect } from 'react';
import { FlutterForm, FlutterFormField } from '@openwebf/react-core-ui';
import { FlutterCupertinoSwitch } from '@openwebf/react-cupertino-ui';
import styles from './FormPage.module.css';

export const FormPage: React.FC = () => {
  const [formResult, setFormResult] = useState<string | null>(null);
  const [currentLayout, setCurrentLayout] = useState<'vertical' | 'horizontal'>('vertical');
  const [validationErrorMessage, setValidationErrorMessage] = useState('');
  const [, setIsSubmitting] = useState(false);

  const demoFormRef = useRef<any>(null);
  const usernameFieldRef = useRef<any>(null);
  const emailFieldRef = useRef<any>(null);
  const ageFieldRef = useRef<any>(null);
  const websiteFieldRef = useRef<any>(null);
  const passwordFieldRef = useRef<any>(null);

  const layoutDisplayName = currentLayout === 'vertical' ? 'Vertical Layout' : 'Horizontal Layout';

  const onScreen = () => {
    setupFormRules();
  };

  const setupFormRules = () => {
    // Username field rules
    usernameFieldRef.current?.setRules([
      { 
        required: true, 
        message: "Please enter username" 
      },
      { 
        minLength: 3, 
        maxLength: 20, 
        message: "Username must be between 3-20 characters" 
      }
    ]);
    
    // Email field rules
    emailFieldRef.current?.setRules([
      { 
        type: "email", 
        message: "Please enter a valid email address" 
      }
    ]);
    
    // Age field rules
    ageFieldRef.current?.setRules([
      { 
        type: "number", 
        min: 18, 
        max: 120, 
        message: "Age must be between 18-120" 
      }
    ]);
    
    // Website field rules
    websiteFieldRef.current?.setRules([
      { 
        type: "url", 
        message: "Please enter a valid URL" 
      }
    ]);
    
    // Password field rules
    passwordFieldRef.current?.setRules([
      { 
        required: true, 
        message: "Please enter password" 
      },
      { 
        minLength: 6, 
        message: "Password must be at least 6 characters" 
      }
    ]);
  };

  const setLayout = (layout: 'vertical' | 'horizontal') => {
    setCurrentLayout(layout);
    
    // Manually update form layout attribute
    demoFormRef.current?.setAttribute('layout', layout);
  };

  const handleLayoutChange = (event: any) => {
    // Switch on means horizontal layout, off means vertical layout
    const layout = event.detail ? 'horizontal' : 'vertical';
    setLayout(layout);
  };

  const submitForm = () => {
    setIsSubmitting(true);
    setValidationErrorMessage(''); // Clear previous error messages
    
    // Directly call the form's validateAndSubmit method
    demoFormRef.current?.validateAndSubmit();
  };

  const handleValidationError = () => {
    setIsSubmitting(false);
    setValidationErrorMessage('Form validation failed, please check your inputs');
    
    // Handle validation errors, such as scrolling to the first error field
    console.log('Form validation error');
  };

  const handleSubmit = () => {
    setIsSubmitting(false);
    setValidationErrorMessage('');
    
    // Get form data
    const formData = demoFormRef.current?.getFormValues();
    
    // Display submission data
    setFormResult(JSON.stringify(formData, null, 2));
    
    console.log('Form submission data:', formData);
  };

  const resetForm = () => {
    // Reset form
    demoFormRef.current?.resetForm();
    setFormResult(null);
    setValidationErrorMessage('');
  };

  useEffect(() => {
    // Setup form rules when component mounts
    const timer = setTimeout(() => {
      setupFormRules();
    }, 100);
    return () => clearTimeout(timer);
  }, []);

  return (
    <div className={styles.pageContainer} onLoad={onScreen}>
      {/* Layout Selector */}
      <div className={styles.layoutSelector}>
        <div className={styles.layoutSwitchContainer}>
          <span className={styles.layoutLabel}>Vertical</span>
          <FlutterCupertinoSwitch 
            checked={currentLayout === 'horizontal'} 
            onChange={handleLayoutChange}
            active-color="#1890ff"
          />
          <span className={styles.layoutLabel}>Horizontal</span>
        </div>
      </div>

      <div className={styles.formContainer}>
        <h2>Form Validation Demo - {layoutDisplayName}</h2>
        
        {/* Validation Error Message Area */}
        {validationErrorMessage && (
          <div className={styles.validationError}>
            {validationErrorMessage}
          </div>
        )}
        
        <FlutterForm 
          ref={demoFormRef} 
          layout={currentLayout} 
          validateOnSubmit
          onSubmit={handleSubmit}
          onValidationError={handleValidationError}
        >
          {/* Username Field - Required + Length Validation */}
          <FlutterFormField 
            id="username-field"
            className={styles.formField}
            ref={usernameFieldRef}
            name="username" 
            label="Username" 
          >
            <input 
              type="text" 
              className={styles.formInput}
              placeholder="Enter username"
            />
          </FlutterFormField>
          
          {/* Email Field - Email Format Validation */}
          <FlutterFormField 
            className={styles.formField}
            ref={emailFieldRef}
            name="email" 
            label="Email" 
          >
            <input 
              type="email" 
              className={styles.formInput}
              placeholder="Enter email address" 
            />
          </FlutterFormField>
          
          {/* Age Field - Number Range Validation */}
          <FlutterFormField 
            className={styles.formField}
            ref={ageFieldRef}
            name="age" 
            label="Age" 
            type="number"
          >
            <input 
              type="number" 
              className={styles.formInput}
              placeholder="Enter age" 
            />
          </FlutterFormField>
          
          {/* Website Field - URL Validation */}
          <FlutterFormField 
            className={styles.formField}
            ref={websiteFieldRef}
            name="website" 
            label="Website" 
            type="url"
          >
            <input 
              type="url" 
              className={styles.formInput}
              placeholder="Enter website URL" 
            />
          </FlutterFormField>
          
          {/* Password Field - Required + Length Validation */}
          <FlutterFormField 
            className={styles.formField}
            ref={passwordFieldRef}
            name="password" 
            label="Password"
            type="password"
          >
            <input 
              type="password" 
              className={styles.formInput}
              placeholder="Enter password" 
            />
          </FlutterFormField>
          
          <div className={styles.formActions}>
            {/* Using regular button instead of specific submit button component */}
            <button 
              type="button" 
              className={styles.submitButton}
              onClick={submitForm}
            >Submit</button>
            <button type="button" onClick={resetForm}>Reset</button>
          </div>
        </FlutterForm>
        
        {formResult && (
          <div className={styles.formResult}>
            <h3>Form Submission Result:</h3>
            <pre>{formResult}</pre>
          </div>
        )}
      </div>
    </div>
  );
};