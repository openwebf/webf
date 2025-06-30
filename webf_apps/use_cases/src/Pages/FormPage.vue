<template>
  <div class="page-container" @onscreen="onScreen">
    <!-- Layout Selector -->
    <div class="layout-selector">
      <div class="layout-switch-container">
        <span class="layout-label">Vertical</span>
        <flutter-cupertino-switch 
          :checked="currentLayout === 'horizontal'" 
          @change="handleLayoutChange"
          active-color="#1890ff"
        />
        <span class="layout-label">Horizontal</span>
      </div>
    </div>

    <div class="form-container">
      <h2>Form Validation Demo - {{ layoutDisplayName }}</h2>
      
      <!-- Validation Error Message Area -->
      <div v-if="validationErrorMessage" class="validation-error">
        {{ validationErrorMessage }}
      </div>
      
      <flutter-webf-form 
        ref="demoForm" 
        :layout="currentLayout" 
        validateOnSubmit
        @submit="handleSubmit"
        @validation-error="handleValidationError"
      >
        <!-- Username Field - Required + Length Validation -->
        <flutter-webf-form-field 
          id="username-field"
          ref="usernameField"
          name="username" 
          label="Username" 
        >
          <input 
            type="text" 
            placeholder="Enter username"
          />
        </flutter-webf-form-field>
        
        <!-- Email Field - Email Format Validation -->
        <flutter-webf-form-field 
          ref="emailField"
          name="email" 
          label="Email" 
        >
          <input 
            type="email" 
            placeholder="Enter email address" 
          />
        </flutter-webf-form-field>
        
        <!-- Age Field - Number Range Validation -->
        <flutter-webf-form-field 
          ref="ageField"
          name="age" 
          label="Age" 
          type="number"
        >
          <input 
            type="number" 
            placeholder="Enter age" 
          />
        </flutter-webf-form-field>
        
        <!-- Website Field - URL Validation -->
        <flutter-webf-form-field 
          ref="websiteField"
          name="website" 
          label="Website" 
          type="url"
        >
          <input 
            type="url" 
            placeholder="Enter website URL" 
          />
        </flutter-webf-form-field>
        
        <!-- Password Field - Required + Length Validation -->
        <flutter-webf-form-field 
          ref="passwordField"
          name="password" 
          label="Password"
          type="password"
        >
          <input 
            type="password" 
            placeholder="Enter password" 
          />
        </flutter-webf-form-field>
        
        <div class="form-actions">
          <!-- Using regular button instead of specific submit button component -->
          <button 
            type="button" 
            class="submit-button"
            @click="submitForm"
          >Submit</button>
          <button type="button" @click="resetForm">Reset</button>
        </div>
      </flutter-webf-form>
      
      <div v-if="formResult" class="form-result">
        <h3>Form Submission Result:</h3>
        <pre>{{ formResult }}</pre>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'FormPage',
  data() {
    return {
      formResult: null,
      currentLayout: 'vertical',
      validationErrorMessage: '',
      isSubmitting: false
    };
  },
  computed: {
    layoutDisplayName() {
      const map = {
        'vertical': 'Vertical Layout',
        'horizontal': 'Horizontal Layout'
      };
      return map[this.currentLayout] || 'Vertical Layout';
    }
  },
  methods: {
    onScreen() {
      this.setupFormRules();
    },
    setupFormRules() {
      // Username field rules
      this.$refs.usernameField.setRules([
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
      this.$refs.emailField.setRules([
        { 
          type: "email", 
          message: "Please enter a valid email address" 
        }
      ]);
      
      // Age field rules
      this.$refs.ageField.setRules([
        { 
          type: "number", 
          min: 18, 
          max: 120, 
          message: "Age must be between 18-120" 
        }
      ]);
      
      // Website field rules
      this.$refs.websiteField.setRules([
        { 
          type: "url", 
          message: "Please enter a valid URL" 
        }
      ]);
      
      // Password field rules
      this.$refs.passwordField.setRules([
        { 
          required: true, 
          message: "Please enter password" 
        },
        { 
          minLength: 6, 
          message: "Password must be at least 6 characters" 
        }
      ]);
    },
    setLayout(layout) {
      this.currentLayout = layout;
      
      // Manually update form layout attribute
      this.$refs.demoForm.setAttribute('layout', layout);
    },
    handleLayoutChange(event) {
      // Switch on means horizontal layout, off means vertical layout
      const layout = event.detail ? 'horizontal' : 'vertical';
      this.setLayout(layout);
    },
    submitForm() {
      this.isSubmitting = true;
      this.validationErrorMessage = ''; // Clear previous error messages
      
      // Directly call the form's validateAndSubmit method
      this.$refs.demoForm.validateAndSubmit();
    },
    handleValidationError() {
      this.isSubmitting = false;
      this.validationErrorMessage = 'Form validation failed, please check your inputs';
      
      // Handle validation errors, such as scrolling to the first error field
      console.log('Form validation error');
    },
    handleSubmit() {
      this.isSubmitting = false;
      this.validationErrorMessage = '';
      
      // Get form data
      const formData = this.$refs.demoForm.getFormValues();
      
      // Display submission data
      this.formResult = formData;
      
      console.log('Form submission data:', formData);
    },
    resetForm() {
      // Reset form
      this.$refs.demoForm.resetForm();
      this.formResult = null;
      this.validationErrorMessage = '';
    }
  }
};
</script>

<style scoped>
.page-container {
  width: 100%;
  height: 100vh;
  overflow-y: auto;
  padding: 16px;
  box-sizing: border-box;
  background-color: #f5f5f5;
}

.layout-selector {
  display: flex;
  margin-bottom: 20px;
  justify-content: center;
}

.layout-switch-container {
  display: flex;
  align-items: center;
  background-color: white;
  padding: 10px 16px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.layout-label {
  font-size: 14px;
  color: #333;
  margin: 0 10px;
}

.validation-error {
  color: #ff4d4f;
  margin-bottom: 16px;
  padding: 10px;
  background-color: #fff2f0;
  border: 1px solid #ffccc7;
  border-radius: 4px;
}

.form-container {
  max-width: 800px;
  margin: 0 auto 20px;
  padding: 20px;
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.form-container-inline {
  max-width: 100%;
}

.inline-form-content {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  align-items: flex-end;
}

h2, h3 {
  margin-bottom: 24px;
  text-align: center;
  color: #333;
}

h3 {
  margin-bottom: 16px;
}

flutter-webf-form-field {
  display: block;
  margin-bottom: 16px;
}

input {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 16px;
  box-sizing: border-box;
}

.form-actions {
  display: flex;
  margin-top: 24px;
  margin-bottom: 16px;
}

.form-actions button {
  margin-right: 10px;
}

.form-actions button:last-child {
  margin-right: 0;
}

button {
  padding: 10px 15px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 16px;
  background-color: #f0f0f0;
  color: #333;
}

.form-result {
  margin-top: 30px;
  padding: 15px;
  background-color: #f9f9f9;
  border-radius: 4px;
  border: 1px solid #eee;
}

pre {
  white-space: pre-wrap;
  word-break: break-all;
  overflow-x: auto;
  max-width: 100%;
}

.submit-button {
  padding: 10px 15px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 16px;
  background-color: #1890ff;
  color: white;
}
</style>
