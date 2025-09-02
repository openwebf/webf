import React, { useState } from 'react';
import { useForm, useFieldArray } from 'react-hook-form';
import { WebFListView } from '@openwebf/react-core-ui';
import styles from './FormAdvancedPage.module.css';

// Simplified form data structure
interface FormData {
  // Basic Information
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
  
  // Address Information  
  city: string;
  zipCode: string;
  
  // Professional Information
  company: string;
  position: string;
  salary: string;
  
  // Skills List (Dynamic Array)
  skills: Array<{
    name: string;
    level: string;
  }>;
  
  // Social Links
  website: string;
}

export const FormAdvancedPage: React.FC = () => {
  const [submitResult, setSubmitResult] = useState<string>('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  // React Hook Form Configuration
  const {
    register,
    formState: { errors, isValid, isDirty },
    reset,
    watch,
    setValue,
    getValues,
    trigger,
    control,
  } = useForm<FormData>({
    mode: 'onChange',
    defaultValues: {
      firstName: '',
      lastName: '',
      email: '',
      phone: '',
      city: '',
      zipCode: '',
      company: '',
      position: '',
      salary: '',
      skills: [
        { name: '', level: '' }
      ],
      website: '',
    }
  });

  const watchedValues = watch();

  // useFieldArray for dynamic skills
  const { fields, append, remove } = useFieldArray({
    control,
    name: 'skills'
  });

  // Form submission handler
  const onSubmit = async (data: FormData) => {
    setIsSubmitting(true);
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1500));
      
      setSubmitResult(`🎉 Form submitted successfully!\n${JSON.stringify(data, null, 2)}`);
      console.log('Form submission data:', data);
    } catch (error) {
      setSubmitResult(`Submission error: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setIsSubmitting(false);
    }
  };

  const onError = (errors: any) => {
    console.log('Form validation errors:', errors);
    setSubmitResult(`Validation failed, please fix the following errors:\n${JSON.stringify(errors, null, 2)}`);
  };

  // WebF-adapted submission handler
  const handleFormSubmit = async () => {
    const isFormValid = await trigger();
    
    if (!isFormValid) {
      onError(errors);
      return;
    }
    
    const data = getValues();
    await onSubmit(data);
  };

  const resetForm = () => {
    reset();
    setSubmitResult('');
  };

  // Fill sample data
  const fillSampleData = () => {
    setValue('firstName', 'John');
    setValue('lastName', 'Doe');
    setValue('email', 'john.doe@example.com');
    setValue('phone', '+1-555-123-4567');
    setValue('city', 'New York');
    setValue('zipCode', '100001');
    setValue('company', 'Tech Solutions Inc.');
    setValue('position', 'Frontend Engineer');
    setValue('salary', '75000');
    setValue('website', 'https://johndoe.dev');
    
    // Just fill the existing first skill
    setValue('skills.0.name', 'JavaScript');
    setValue('skills.0.level', 'Advanced');
  };

  // Add skill
  const addSkill = () => {
    append({ name: '', level: '' });
  };

  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.pageContainer}>
          
          {/* Page Header */}
          <div className={styles.header}>
            <div className={styles.headerContent}>
              <h1 className={styles.title}>✨ User Information Form</h1>
              <p className={styles.subtitle}>
                Complete user information collection form based on React Hook Form
              </p>
              <div className={styles.titleDecoration}></div>
            </div>
          </div>

          {/* Form Status Overview */}
          <div className={styles.statusCard}>
            <div className={styles.statusGrid}>
              <div className={styles.statusItem}>
                <span className={styles.statusIcon}>✅</span>
                <div className={styles.statusInfo}>
                  <span className={styles.statusLabel}>Form Status</span>
                  <span className={`${styles.statusValue} ${isValid ? styles.valid : styles.invalid}`}>
                    {isValid ? 'Valid' : 'Invalid'}
                  </span>
                </div>
              </div>
              
              <div className={styles.statusItem}>
                <span className={styles.statusIcon}>✏️</span>
                <div className={styles.statusInfo}>
                  <span className={styles.statusLabel}>Dirty Status</span>
                  <span className={`${styles.statusValue} ${isDirty ? styles.dirty : ''}`}>
                    {isDirty ? 'Modified' : 'Pristine'}
                  </span>
                </div>
              </div>
              
              <div className={styles.statusItem}>
                <span className={styles.statusIcon}>🐛</span>
                <div className={styles.statusInfo}>
                  <span className={styles.statusLabel}>Error Count</span>
                  <span className={`${styles.statusValue} ${Object.keys(errors).length > 0 ? styles.hasErrors : ''}`}>
                    {Object.keys(errors).length}
                  </span>
                </div>
              </div>
            </div>
          </div>

          {/* Personal Basic Information */}
          <div className={styles.section}>
            <div className={styles.sectionHeader}>
              <h2 className={styles.sectionTitle}>
                <span className={styles.sectionIcon}>👤</span>
Personal Basic Information
              </h2>
            </div>
            
            <div className={styles.card}>
              <div className={styles.field}>
                <label className={styles.label}>
                  <span className={styles.labelText}>First Name</span>
                  <span className={styles.required}>*</span>
                </label>
                <input
                  {...register('firstName', {
                    required: 'First name is required',
                    minLength: { value: 2, message: 'First name must be at least 2 characters' }
                  })}
                  className={`${styles.input} ${errors.firstName ? styles.inputError : ''}`}
                  placeholder="Enter your first name"
                />
                {errors.firstName && (
                  <span className={styles.errorMessage}>
                    <span className={styles.errorIcon}>⚠️</span>
                    {errors.firstName.message}
                  </span>
                )}
              </div>

              <div className={styles.field}>
                <label className={styles.label}>
                  <span className={styles.labelText}>Last Name</span>
                  <span className={styles.required}>*</span>
                </label>
                <input
                  {...register('lastName', {
                    required: 'Last name is required',
                    minLength: { value: 1, message: 'Last name must be at least 1 character' }
                  })}
                  className={`${styles.input} ${errors.lastName ? styles.inputError : ''}`}
                  placeholder="Enter your last name"
                />
                {errors.lastName && (
                  <span className={styles.errorMessage}>
                    <span className={styles.errorIcon}>⚠️</span>
                    {errors.lastName.message}
                  </span>
                )}
              </div>

              <div className={styles.field}>
                <label className={styles.label}>
                  <span className={styles.labelText}>Email Address</span>
                  <span className={styles.required}>*</span>
                </label>
                <input
                  {...register('email', {
                    required: 'Email is required',
                    pattern: {
                      value: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i,
                      message: 'Please enter a valid email address'
                    }
                  })}
                  className={`${styles.input} ${errors.email ? styles.inputError : ''}`}
                  placeholder="example@email.com"
                />
                {errors.email && (
                  <span className={styles.errorMessage}>
                    <span className={styles.errorIcon}>⚠️</span>
                    {errors.email.message}
                  </span>
                )}
              </div>

              <div className={styles.field}>
                <label className={styles.label}>
                  <span className={styles.labelText}>Phone Number</span>
                </label>
                <input
                  {...register('phone', {
                    pattern: {
                      value: /^[+]?[\d\s\-()]+$/,
                      message: 'Please enter a valid phone number'
                    }
                  })}
                  className={`${styles.input} ${errors.phone ? styles.inputError : ''}`}
                  placeholder="+86-138-0013-8000"
                />
                {errors.phone && (
                  <span className={styles.errorMessage}>
                    <span className={styles.errorIcon}>⚠️</span>
                    {errors.phone.message}
                  </span>
                )}
              </div>
            </div>
          </div>

          {/* Address Information */}
          <div className={styles.section}>
            <div className={styles.sectionHeader}>
              <h2 className={styles.sectionTitle}>
                <span className={styles.sectionIcon}>🏠</span>
Address Information
              </h2>
            </div>
            
            <div className={styles.card}>
              <div className={styles.field}>
                <label className={styles.label}>
                  <span className={styles.labelText}>City</span>
                </label>
                <input
                  {...register('city')}
                  className={styles.input}
                  placeholder="New York"
                />
              </div>

              <div className={styles.field}>
                <label className={styles.label}>
                  <span className={styles.labelText}>Postal Code</span>
                </label>
                <input
                  {...register('zipCode', {
                    pattern: {
                      value: /^\d{6}$/,
                      message: 'Postal code must be 6 digits'
                    }
                  })}
                  className={`${styles.input} ${errors.zipCode ? styles.inputError : ''}`}
                  placeholder="100000"
                />
                {errors.zipCode && (
                  <span className={styles.errorMessage}>
                    <span className={styles.errorIcon}>⚠️</span>
                    {errors.zipCode.message}
                  </span>
                )}
              </div>
            </div>
          </div>

          {/* Professional Information */}
          <div className={styles.section}>
            <div className={styles.sectionHeader}>
              <h2 className={styles.sectionTitle}>
                <span className={styles.sectionIcon}>💼</span>
Professional Information
              </h2>
            </div>
            
            <div className={styles.card}>
              <div className={styles.field}>
                <label className={styles.label}>
                  <span className={styles.labelText}>Company Name</span>
                </label>
                <input
                  {...register('company')}
                  className={styles.input}
                  placeholder="Tech Solutions Inc."
                />
              </div>

              <div className={styles.field}>
                <label className={styles.label}>
                  <span className={styles.labelText}>Position</span>
                </label>
                <input
                  {...register('position')}
                  className={styles.input}
                  placeholder="Frontend Engineer"
                />
              </div>

              <div className={styles.field}>
                <label className={styles.label}>
                  <span className={styles.labelText}>Expected Salary (Annual)</span>
                </label>
                <input
                  {...register('salary', {
                    pattern: {
                      value: /^\d+$/,
                      message: 'Salary must be numeric'
                    }
                  })}
                  className={`${styles.input} ${errors.salary ? styles.inputError : ''}`}
                  placeholder="75000"
                />
                {errors.salary && (
                  <span className={styles.errorMessage}>
                    <span className={styles.errorIcon}>⚠️</span>
                    {errors.salary.message}
                  </span>
                )}
              </div>
            </div>
          </div>

          {/* Skills List */}
          <div className={styles.section}>
            <div className={styles.sectionHeader}>
              <h2 className={styles.sectionTitle}>
                <span className={styles.sectionIcon}>🎯</span>
Skills List
              </h2>
              <button
                type="button"
                onClick={addSkill}
                className={styles.addButton}
                disabled={isSubmitting}
              >
                <span className={styles.addIcon}>+</span>
Add Skill
              </button>
            </div>
            
            <div className={styles.card}>
              <div className={styles.skillsList}>
                {fields.map((field, index) => (
                  <div key={field.id} className={styles.skillItem}>
                    <div className={styles.skillNumber}>{index + 1}</div>
                    <div className={styles.skillFields}>
                      <div className={styles.field}>
                        <label className={styles.label}>
                          <span className={styles.labelText}>Skill Name</span>
                          <span className={styles.required}>*</span>
                        </label>
                        <input
                          {...register(`skills.${index}.name`, {
                            required: 'Skill name is required'
                          })}
                          className={`${styles.input} ${errors.skills?.[index]?.name ? styles.inputError : ''}`}
                          placeholder="e.g., JavaScript, React, UI Design"
                        />
                        {errors.skills?.[index]?.name && (
                          <span className={styles.errorMessage}>
                            <span className={styles.errorIcon}>⚠️</span>
                            {errors.skills[index]?.name?.message}
                          </span>
                        )}
                      </div>

                      <div className={styles.field}>
                        <label className={styles.label}>
                          <span className={styles.labelText}>Skill Level</span>
                        </label>
                        <input
                          {...register(`skills.${index}.level`)}
                          className={styles.input}
                          placeholder="Beginner/Intermediate/Advanced/Expert"
                        />
                      </div>
                    </div>
                    
                    {fields.length > 1 && (
                      <button
                        type="button"
                        onClick={() => remove(index)}
                        className={styles.removeButton}
                        disabled={isSubmitting}
                      >
                        <span className={styles.removeIcon}>×</span>
                      </button>
                    )}
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Social Links */}
          <div className={styles.section}>
            <div className={styles.sectionHeader}>
              <h2 className={styles.sectionTitle}>
                <span className={styles.sectionIcon}>🔗</span>
Social Links
              </h2>
            </div>
            
            <div className={styles.card}>
              <div className={styles.field}>
                <label className={styles.label}>
                  <span className={styles.labelText}>Personal Website</span>
                </label>
                <input
                  {...register('website', {
                    pattern: {
                      value: /^https?:\/\/.+/,
                      message: 'Please enter a valid URL starting with http:// or https://'
                    }
                  })}
                  className={`${styles.input} ${errors.website ? styles.inputError : ''}`}
                  placeholder="https://yourwebsite.com"
                />
                {errors.website && (
                  <span className={styles.errorMessage}>
                    <span className={styles.errorIcon}>⚠️</span>
                    {errors.website.message}
                  </span>
                )}
              </div>

            </div>
          </div>

          {/* Form Actions */}
          <div className={styles.section}>
            <div className={styles.actionCard}>
              <div className={styles.actions}>
                <button
                  type="button"
                  onClick={handleFormSubmit}
                  disabled={isSubmitting}
                  className={`${styles.submitButton} ${isSubmitting ? styles.loading : ''}`}
                >
                  {isSubmitting ? (
                    <>
                      Submitting...
                    </>
                  ) : (
                    <>
                      <span className={styles.buttonIcon}>🚀</span>
                      Submit Form
                    </>
                  )}
                </button>
                
                <button
                  type="button"
                  onClick={resetForm}
                  className={styles.resetButton}
                  disabled={isSubmitting}
                >
                  <span className={styles.buttonIcon}>🔄</span>
                  Reset Form
                </button>

                <button
                  type="button"
                  onClick={fillSampleData}
                  className={styles.demoButton}
                  disabled={isSubmitting}
                >
                  <span className={styles.buttonIcon}>✨</span>
                  Fill Sample Data
                </button>
              </div>
            </div>
          </div>

          {/* Submission Result Display */}
          {submitResult && (
            <div className={styles.resultCard}>
              <div className={styles.resultHeader}>
                <h3 className={styles.resultTitle}>
                  <span className={styles.resultIcon}>📤</span>
                  Form Submission Result
                </h3>
                <button
                  onClick={() => setSubmitResult('')}
                  className={styles.closeButton}
                >
                  ×
                </button>
              </div>
              <pre className={styles.resultContent}>{submitResult}</pre>
            </div>
          )}

          {/* Real-time Form Data Preview */}
          <details className={styles.debugCard}>
            <summary className={styles.debugTitle}>
              <span className={styles.debugIcon}>🔍</span>
              Real-time Form Data Preview
            </summary>
            <div className={styles.debugContent}>
              <pre>{JSON.stringify(watchedValues, null, 2)}</pre>
            </div>
          </details>
        </div>
      </WebFListView>
    </div>
  );
};